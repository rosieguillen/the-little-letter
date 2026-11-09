require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  test "redirects to the cart when checkout is empty" do
    get checkout_path

    assert_redirected_to cart_path
  end

  test "reviews and places a guest order at the displayed total" do
    category = Category.create!(name: "Notebooks", slug: "checkout-test-notebooks")
    product = category.products.create!(name: "Notebook", description: "Ruled pages", price_cents: 1295)
    Province.create!(code: "MB", name: "Manitoba", gst_rate: "0.05", pst_rate: "0.07")

    post cart_items_path, params: { product_id: product.id }
    post cart_items_path, params: { product_id: product.id }
    details = {
      name: "Sample Shopper", email: "shopper@example.com", phone: "",
      street: "123 Sample Street", city: "Winnipeg", postal_code: "R3C 0A1", province: "MB"
    }

    post review_checkout_path, params: { checkout_details: details }
    assert_response :success
    assert_select "strong", "Total: $29.01 CAD"

    assert_difference "Order.count", 1 do
      post place_order_path, params: { checkout_details: details }
    end
    assert_redirected_to checkout_confirmation_path
    follow_redirect!
    assert_select "h1", "Order confirmed"

    order = Order.find_by!(email: details[:email])
    assert_equal 2901, order.total_cents
    assert_equal [ product.id, 2, 1295 ],
      order.order_items.sole.values_at(:product_id, :quantity, :unit_price_cents)
    get cart_path
    assert_select "p", "Your cart is empty."
  end
end
