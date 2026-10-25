# frozen_string_literal: true

require 'test_helper'
require 'openssl'

class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @old_webhook_secret = ENV.fetch('GITHUB_WEBHOOK_SECRET', nil)
    ENV['GITHUB_WEBHOOK_SECRET'] = 'test-webhook-secret'
  end

  teardown do
    if @old_webhook_secret
      ENV['GITHUB_WEBHOOK_SECRET'] = @old_webhook_secret
    else
      ENV.delete('GITHUB_WEBHOOK_SECRET')
    end
  end

  def build_repo(github_id:)
    user = User.create!(email: 'api-owner@example.com')
    user.repositories.create!(
      github_id:,
      name: 'example',
      full_name: 'TheGor-365/example',
      language: 'ruby',
      clone_url: 'https://github.com/TheGor-365/example.git',
      ssh_url: 'git@github.com:TheGor-365/example.git'
    )
  end

  def post_signed_hook(payload, event: 'push', signature: nil)
    body = payload.is_a?(String) ? payload : payload.to_json
    signature ||= "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', ENV.fetch('GITHUB_WEBHOOK_SECRET'), body)}"
    post api_checks_path,
         params: body,
         headers: {
           'CONTENT_TYPE' => 'application/json',
           'X-GitHub-Event' => event,
           'X-Hub-Signature-256' => signature
         }
  end

  test 'valid signed push creates check asynchronously' do
    repo = build_repo(github_id: 345)
    payload = { 'repository' => { 'id' => repo.github_id }, 'after' => 'abc123def456' }

    assert_difference -> { repo.checks.count }, 1 do
      assert_enqueued_with(job: RunRepositoryCheckJob) do
        post_signed_hook(payload)
      end
    end

    assert_response :accepted
  end

  test 'unsigned webhooks are rejected' do
    repo = build_repo(github_id: 345)

    assert_no_difference -> { repo.checks.count } do
      post api_checks_path,
           params: { repository: { id: repo.github_id } }.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json', 'X-GitHub-Event' => 'push' }
    end

    assert_response :unauthorized
  end

  test 'invalid webhook signature is rejected' do
    post_signed_hook({ repository: { id: 123 } }, signature: "sha256=#{'0' * 64}")
    assert_response :unauthorized
  end

  test 'non-push events are ignored' do
    post_signed_hook({}, event: 'ping')
    assert_response :unprocessable_entity
  end

  test 'nonexistent repository returns not found' do
    post_signed_hook({ 'repository' => { 'id' => 999_999 }, 'after' => 'x' })
    assert_response :not_found
  end

  test 'invalid json returns unprocessable entity when signed' do
    post_signed_hook('{')
    assert_response :unprocessable_entity
  end
end
