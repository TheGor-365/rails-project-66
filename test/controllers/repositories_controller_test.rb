require "test_helper"

class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  test "guest is redirected from index" do
    get repositories_url

    assert_redirected_to root_url
  end
end
