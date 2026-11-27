require "test_helper"

class CustomerOrdersTest < ActionDispatch::IntegrationTest
  setup do
    @province = Province.create!(code: "MB", name: "Manitoba", gst_rate: "0.05", pst_rate: "0.07")
    category = Category.create!(name: "History", slug: "history")
    @product = category.products.create!(name: "Original notebook", description: "Notebook", price_cents: 1000)
    @customer = account("shopper")
    @other = account("another")
  end

  test "requires customer authentication including after logout" do
    get customer_orders_path
    assert_redirected_to customer_sign_in_path
    login
    get customer_orders_path
    assert_response :success
    delete customer_sign_out_path
    get customer_orders_path
    assert_redirected_to customer_sign_in_path
  end

  test "empty history offers shopping and is linked from account" do
    login
    get customer_orders_path
    assert_select "h2", "No orders yet"
    assert_select "a[href=?]", root_path, text: "Shop stationery"
    get customer_account_path
    assert_select "a[href=?]", customer_orders_path, text: "View my orders"
  end

  test "only own orders appear with saved prices taxes and delivery" do
    own = place(@customer)
    foreign = place(@other)
    @product.update!(name: "Changed product", price_cents: 9900)
    @province.update!(gst_rate: "0.09")
    @customer.update!(street: "New account address")
    login
    get customer_orders_path, params: { customer_id: @other.id }
    assert_response :success
    assert_select "article[aria-labelledby='order-#{own.id}']" do
      assert_select "td", text: "Original notebook"
      assert_select "td", text: "2"
      assert_select "td", text: "$10.00"
      assert_select "td", text: "$20.00"
      assert_select "dd", text: "$22.40 CAD"
      assert_select "dt", text: "GST (5%)"
      assert_select "p", text: /123 Saved Street/
    end
    assert_select "article[aria-labelledby='order-#{foreign.id}']", count: 0
    assert_no_match "Changed product", response.body
    assert_no_match "New account address", response.body
  end

  test "history paginates newest orders first" do
    11.times { place(@customer) }
    login
    get customer_orders_path
    assert_select "article.order-card", count: 10
    newest = @customer.orders.order(created_at: :desc, id: :desc).first
    assert_select "article.order-card:first-of-type h2", "Order ##{newest.id}"
    get customer_orders_path, params: { page: 2 }
    assert_select "article.order-card", count: 1
  end

  private

  def account(username)
    Customer.create!(username: username, password: "sample-password-123", password_confirmation: "sample-password-123",
      name: username, email: "#{username}@example.com", street: "123 Saved Street", city: "Winnipeg",
      postal_code: "R3C 0A1", province: @province)
  end

  def login
    post customer_sign_in_path, params: { customer: { username: @customer.username, password: "sample-password-123" } }
  end

  def place(customer)
    details = CheckoutDetails.new(customer.attributes.slice("name", "email", "phone", "street", "city", "postal_code").merge("province" => "MB"))
    invoice = CheckoutInvoice.new(quantities: { @product.id.to_s => 2 }, province: @province)
    CheckoutOrder.place!(details: details, invoice: invoice, customer: customer)
  end
end
