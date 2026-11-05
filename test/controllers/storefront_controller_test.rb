require "test_helper"

class StorefrontControllerTest < ActionDispatch::IntegrationTest
  test "shows The Little Letter homepage" do
    get root_url
    assert_response :success
    assert_select "h1", "The Little Letter"
  end
end
