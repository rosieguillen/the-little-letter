require "test_helper"

class StorePagesTest < ActionDispatch::IntegrationTest
  setup do
    @page = StorePage.create!(slug: "contact", title: "Contact", body: "Welcome to our shop.")
  end

  test "public pages are readable and escape entered markup" do
    @page.update!(body: "<script>alert('test')</script>", email: "shop@example.com", opening_hours: "Monday\nTuesday")
    get contact_path
    assert_response :success
    assert_select "a[href='mailto:shop@example.com']"
    assert_select ".store-page-copy script", count: 0
    assert_select ".store-page-copy", text: "<script>alert('test')</script>"
  end

  test "page editing requires staff" do
    get admin_store_pages_path
    assert_redirected_to admin_sign_in_path
    patch admin_store_page_path(@page), params: { store_page: { body: "Unauthorized" } }
    assert_redirected_to admin_sign_in_path
    assert_equal "Welcome to our shop.", @page.reload.body
  end

  test "staff edits are public and invalid content is rejected" do
    admin = Admin.create!(username: "page-staff", password: "page-test-password")
    post admin_sign_in_path, params: { admin: { username: admin.username, password: "page-test-password" } }
    get edit_admin_store_page_path(@page)
    assert_response :success
    patch admin_store_page_path(@page), params: {
      store_page: { title: "Contact our shop", body: "Visit us", email: "shop@example.com",
                    phone: "204-555-0100", opening_hours: "Monday 10–5", slug: "changed" }
    }
    assert_redirected_to admin_store_pages_path
    assert_equal "contact", @page.reload.slug
    get contact_path
    assert_select "h1", "Contact our shop"
    assert_select "dd", "204-555-0100"
    patch admin_store_page_path(@page), params: { store_page: { title: "", email: "bad-email" } }
    assert_response :unprocessable_entity
    assert_select "[role='alert']"
    assert_equal "Contact our shop", @page.reload.title
  end

  test "seeding does not overwrite staff edits" do
    load Rails.root.join("db/seeds/store_pages.rb")
    assert_equal "Welcome to our shop.", @page.reload.body
    assert StorePage.exists?(slug: "about")
  end
end
