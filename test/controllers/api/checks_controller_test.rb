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

  def post_signed_hook(payload, event: 'push', signature: nil, delivery_id: SecureRandom.uuid)
    body = payload.is_a?(String) ? payload : payload.to_json
    signature ||= "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', ENV.fetch('GITHUB_WEBHOOK_SECRET'), body)}"
    post api_checks_path,
         params: body,
         headers: {
           'CONTENT_TYPE' => 'application/json',
           'X-GitHub-Event' => event,
           'X-GitHub-Delivery' => delivery_id,
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

  test 'repeated delivery does not create another check or enqueue another job' do
    repo = build_repo(github_id: 346)
    payload = { 'repository' => { 'id' => repo.github_id }, 'after' => 'abc123def456' }
    delivery_id = SecureRandom.uuid

    assert_difference -> { repo.checks.count }, 1 do
      assert_enqueued_jobs 1, only: RunRepositoryCheckJob do
        post_signed_hook(payload, delivery_id:)
      end
    end
    assert_response :accepted

    assert_no_difference -> { repo.checks.count } do
      assert_no_enqueued_jobs only: RunRepositoryCheckJob do
        post_signed_hook(payload, delivery_id:)
      end
    end
    assert_response :accepted
  end

  test 'another signed delivery creates another check' do
    repo = build_repo(github_id: 347)
    payload = { 'repository' => { 'id' => repo.github_id }, 'after' => 'abc123def456' }

    assert_difference -> { repo.checks.count }, 2 do
      post_signed_hook(payload)
      post_signed_hook(payload)
    end
    assert_response :accepted
  end

  test 'missing delivery id is rejected without creating a check' do
    repo = build_repo(github_id: 348)
    payload = { 'repository' => { 'id' => repo.github_id }, 'after' => 'abc123def456' }

    assert_no_difference -> { repo.checks.count } do
      post_signed_hook(payload, delivery_id: nil)
    end
    assert_response :unprocessable_entity
  end

  test 'deleted branch push is acknowledged without creating a check' do
    repo = build_repo(github_id: 349)
    payload = {
      'repository' => { 'id' => repo.github_id },
      'after' => '0' * 40,
      'deleted' => true
    }

    assert_no_difference -> { repo.checks.count } do
      assert_no_enqueued_jobs only: RunRepositoryCheckJob do
        post_signed_hook(payload)
      end
    end
    assert_response :no_content
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

  test 'signed ping is acknowledged without enqueuing a check' do
    assert_no_enqueued_jobs do
      post_signed_hook({}, event: 'ping')
    end

    assert_response :no_content
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
