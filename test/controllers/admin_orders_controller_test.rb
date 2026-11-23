require "test_helper"

class AdminOrdersControllerTest < ActionDispatch::IntegrationTest
  test "requires staff sign-in" do
    get admin_orders_path
    assert_redirected_to admin_sign_in_path
  end

  test "shows saved order details even after a product is deleted" do
    admin = Admin.create!(username: "history-staff", password: "history-test-password")
    province = Province.create!(code: "MB", name: "Manitoba", gst_rate: "0.05", pst_rate: "0.07")
    category = Category.create!(name: "History notebooks", slug: "history-notebooks")
    product = category.products.create!(name: "Original notebook", description: "Ruled pages", price_cents: 1295)
    details = CheckoutDetails.new(
      name: "History Shopper", email: "history@example.com", street: "123 Sample Street",
      city: "Winnipeg", postal_code: "R3C 0A1", province: "MB"
    )
    invoice = CheckoutInvoice.new(quantities: { product.id.to_s => 2 }, province: province)
    order = CheckoutOrder.place!(details: details, invoice: invoice)
    product.update!(name: "Renamed notebook", price_cents: 9999)
    product.destroy!

    post admin_sign_in_path, params: { admin: { username: admin.username, password: "history-test-password" } }
    get admin_orders_path

    assert_response :success
    assert_select "h2", "Order ##{order.id}"
    assert_select "p", /Customer ##{order.customer_id}.*History Shopper/
    assert_select "td", "Original notebook"
    assert_select "td", "2"
    assert_select "td", "$12.95"
    assert_select "td", "$25.90"
    assert_select "dd", "$1.30 CAD"
    assert_select "dd", "$1.81 CAD"
    assert_select "dd strong", "$29.01 CAD"
    assert_select "td", text: "Renamed notebook", count: 0
  end

  test "shows an empty state for staff" do
    admin = Admin.create!(username: "empty-history-staff", password: "history-test-password")
    post admin_sign_in_path, params: { admin: { username: admin.username, password: "history-test-password" } }
    get admin_orders_path
    assert_response :success
    assert_select "p", "No orders have been placed yet."
  end
end
