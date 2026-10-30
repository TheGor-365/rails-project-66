# frozen_string_literal: true

require 'test_helper'

class Web::LanguagesControllerTest < ActionDispatch::IntegrationTest
  test 'switches to English and keeps it across requests' do
    post language_path(locale: 'en')

    assert_response :see_other
    follow_redirect!

    assert_response :success
    assert_select 'html[lang="en"]'
    assert_select '.gq-locale__button.is-active', text: 'EN'

    get root_path

    assert_response :success
    assert_select 'html[lang="en"]'
    assert_select 'h2', text: 'Repository quality analyzer'
  end

  test 'switches from English back to Russian' do
    post language_path(locale: 'en')
    post language_path(locale: 'ru')
    follow_redirect!

    assert_response :success
    assert_select 'html[lang="ru"]'
    assert_select '.gq-locale__button.is-active', text: 'RU'
  end

  test 'rejects an unsupported language' do
    post language_path(locale: 'de')

    assert_response :not_found
  end
end
