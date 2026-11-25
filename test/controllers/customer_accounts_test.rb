require "test_helper"

class CustomerAccountsTest < ActionDispatch::IntegrationTest
  setup do
    @province = Province.create!(code: "MB", name: "Manitoba", gst_rate: "0.05", pst_rate: "0.07")
    category = Category.create!(name: "Account test", slug: "account-test")
    @product = category.products.create!(name: "Pen", description: "Gel pen", price_cents: 1000)
    @attributes = {
      username: "shopper", password: "shopper-password-123", password_confirmation: "shopper-password-123",
      name: "Sample Shopper", email: "shopper@example.com", phone: "", street: "123 Sample Street",
      city: "Winnipeg", postal_code: "R3C 0A1", province_id: @province.id
    }
  end

  test "sign-up saves hashed credentials and preserves the guest cart" do
    post cart_items_path, params: { product_id: @product.id }
    assert_difference "Customer.count", 1 do
      post customer_sign_up_path, params: { customer: @attributes.merge(username: " SHOPPER ") }
    end
    assert_redirected_to customer_account_path
    customer = Customer.find_by!(username: "shopper")
    assert_not_equal @attributes[:password], customer.password_digest
    assert customer.authenticate(@attributes[:password])
    get customer_account_path
    assert_response :success
    assert_select "input[value='123 Sample Street']"
    get cart_path
    assert_select "a", @product.name
  end

  test "rejects duplicate usernames and invalid passwords or addresses" do
    Customer.create!(@attributes)
    [
      { username: "SHOPPER" },
      { username: "" },
      { username: "newshopper", password: "short", password_confirmation: "short" },
      { username: "newshopper", password_confirmation: "different-password" },
      { username: "newshopper", password_confirmation: "" },
      { username: "newshopper", province_id: nil },
      { username: "newshopper", email: "invalid" }
    ].each do |changes|
      assert_no_difference "Customer.count" do
        post customer_sign_up_path, params: { customer: @attributes.merge(changes) }
      end
      assert_response :unprocessable_entity
      assert_select "[role='alert']"
    end
  end

  test "login and logout protect the account and retain the cart" do
    Customer.create!(@attributes)
    get customer_account_path
    assert_redirected_to customer_sign_in_path
    post customer_sign_in_path, params: { customer: { username: "shopper", password: "wrong" } }
    assert_response :unprocessable_entity
    get customer_account_path
    assert_redirected_to customer_sign_in_path
    post cart_items_path, params: { product_id: @product.id }
    post customer_sign_in_path, params: { customer: { username: "SHOPPER", password: @attributes[:password] } }
    assert_redirected_to customer_account_path
    delete customer_sign_out_path
    get customer_account_path
    assert_redirected_to customer_sign_in_path
    get cart_path
    assert_select "a", @product.name
  end

  test "saved address prefills checkout and order belongs to the signed-in customer" do
    post customer_sign_up_path, params: { customer: @attributes }
    customer = Customer.find_by!(username: "shopper")
    patch customer_account_path, params: { customer: {
      street: "456 Updated Street", customer_id: 999, username: "hijacked"
    } }
    assert_redirected_to customer_account_path
    assert_equal "shopper", customer.reload.username
    post cart_items_path, params: { product_id: @product.id }
    get checkout_path
    assert_response :success
    assert_select "input[name='checkout_details[street]'][value='456 Updated Street']"
    details = @attributes.slice(:name, :email, :phone, :city, :postal_code)
      .merge(street: "Different checkout address", province: "MB")
    post review_checkout_path, params: { checkout_details: details }
    assert_response :success
    assert_no_difference "Customer.count" do
      assert_difference "Order.count", 1 do
        post place_order_path, params: { checkout_details: details, customer_id: 999 }
      end
    end
    assert_redirected_to checkout_confirmation_path
    assert_equal customer.id, Order.last.customer_id
    assert_equal "Different checkout address", Order.last.street
    assert_equal "456 Updated Street", customer.reload.street
  end

  test "existing guest records need no username or password" do
    guest = Customer.create!(@attributes.except(:username, :password, :password_confirmation))
    assert_nil guest.password_digest
    assert guest.update(phone: "204-555-0100")
  end
end
