require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "home index returns success and contains expected text" do
    get root_url
    assert_response :success
    assert_select "h1", "Github Quality"
    assert_select "h2", "Анализатор качества репозиториев"
  end
end
