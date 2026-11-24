require "test_helper"

class StorefrontControllerTest < ActionDispatch::IntegrationTest
  test "shows The Little Letter homepage" do
    get root_url
    assert_response :success
    assert_select "a.site-logo img[alt=?]", "The Little Letter home"
    assert_select "h1", "Shop stationery"
  end
end
