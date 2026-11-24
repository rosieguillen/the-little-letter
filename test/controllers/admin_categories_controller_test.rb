require "test_helper"

class AdminCategoriesControllerTest < ActionDispatch::IntegrationTest
  test "staff can create and rename categories while keeping their URLs" do
    admin = Admin.create!(username: "category-test-staff", password: "category-test-password")
    post admin_sign_in_path, params: { admin: { username: admin.username, password: "category-test-password" } }

    get admin_categories_path
    assert_response :success
    assert_select ".category-management-form"
    assert_difference "Category.count", 1 do
      post admin_categories_path, params: { category: { name: "Greeting Cards" } }
    end
    assert_redirected_to admin_categories_path
    category = Category.find_by!(slug: "greeting-cards")

    assert_no_difference "Category.count" do
      post admin_categories_path, params: { category: { name: "Greeting Cards" } }
    end
    assert_response :unprocessable_entity
    assert_select "[role='alert']"

    get edit_admin_category_path(category)
    assert_response :success
    assert_select "input[value='Greeting Cards']"
    patch admin_category_path(category), params: { category: { name: "Cards and Envelopes" } }
    assert_redirected_to admin_categories_path
    assert_equal "Cards and Envelopes", category.reload.name
    assert_equal "greeting-cards", category.slug
  end
end
