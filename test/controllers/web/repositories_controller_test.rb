# frozen_string_literal: true

require 'test_helper'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test 'guest is redirected from index' do
    get repositories_path

    assert_redirected_to root_path
  end

  test 'guest is redirected from new' do
    get new_repository_path

    assert_redirected_to root_path
  end

  test 'guest is redirected from show' do
    user = User.create!(email: 'u1@example.com')
    repo = user.repositories.create!(
      github_id: 10,
      name: 'r',
      full_name: 'x/y',
      language: 'ruby',
      clone_url: 'https://example.com/r.git',
      ssh_url: 'git@example.com:r.git'
    )

    get repository_path(repo)

    assert_redirected_to root_path
  end

  test 'index returns success for logged in user' do
    sign_in!
    get repositories_path

    assert_response :success
    assert_select '.gq-page', count: 1
    assert_select '.bg-white', count: 0
  end

  test 'new returns success and offers searchable supported GitHub repositories' do
    sign_in!
    get new_repository_path

    assert_response :success
    assert_select '[data-controller="repository-search"]', 1
    assert_select 'input#github_repository_search[type="search"][data-repository-search-target="query"]', 1
    assert_select 'select#repository_github_id[data-repository-search-target="select"]', 1
    assert_select 'select#repository_github_id option[value="9100001"]', text: 'TheGor-365/rails-project'
    assert_select 'select#repository_github_id option[value="9100002"]', text: 'TheGor-365/frontend-check'
    assert_select '[data-repository-search-target="count"]', text: /2/
  end

  test 'create adds repository and redirects' do
    user = sign_in!

    assert_difference -> { user.repositories.count }, 1 do
      perform_enqueued_jobs do
        post repositories_path, params: { repository: { github_id: 1 } }
      end
    end

    assert_redirected_to repositories_path
  end

  test 'show returns success for owner' do
    user = sign_in!

    repo = user.repositories.create!(
      github_id: 10,
      name: 'example',
      full_name: 'TheGor-365/example',
      language: 'ruby',
      clone_url: 'https://github.com/TheGor-365/example.git',
      ssh_url: 'git@github.com:TheGor-365/example.git'
    )

    get repository_path(repo)

    assert_response :success
  end

  test 'show is not accessible for чужой repo' do
    sign_in!(email: 'owner1@example.com')

    owner2 = User.create!(email: 'owner2@example.com')
    repo2 = owner2.repositories.create!(
      github_id: 99,
      name: 'r2',
      full_name: 'x/y2',
      language: 'ruby',
      clone_url: 'https://example.com/r2.git',
      ssh_url: 'git@example.com:r2.git'
    )

    get repository_path(repo2)

    assert_response :not_found
    assert_select 'h1', text: 'Страница не найдена'
    assert_select 'a[href="/"]', text: /На главную/
  end
end
