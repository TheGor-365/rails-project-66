# frozen_string_literal: true

require 'test_helper'

class SiteChromeTest < ActionDispatch::IntegrationTest
  test 'public homepage includes brand metadata and accessible favicon' do
    get root_path

    assert_response :success
    assert_select 'meta[property="og:image"][content$="/og-image.png"]', count: 1
    assert_select 'meta[name="twitter:card"][content="summary_large_image"]', count: 1
    assert_select 'link[rel="icon"][href="/gq-brand-v2.svg"]', count: 1
    assert_select 'link[rel="manifest"][href="/site.webmanifest"]', count: 1
    assert_select 'link[rel="icon"][href="/gq-brand-v2.ico"]', count: 1
    assert Rails.root.join('public/gq-brand-v2.ico').file?
    assert Rails.root.join('public/gq-brand-v2.png').file?
  end

  test 'static error pages use branded dark surfaces and do not leak traces' do
    %w[404 422 500 406-unsupported-browser].each do |name|
      page = Rails.root.join("public/#{name}.html").read
      assert_includes page, 'GitHub Quality'
      assert_includes page, '#0b111d'
      assert_includes page, 'lang="en"'
      assert_includes page, 'noindex,nofollow'
      assert_not_includes page, 'rails-default-error-page'
      assert_not_includes page, 'Exception Backtrace'
    end
  end
end
