require "test_helper"

class AdminProvincesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @province = Province.create!(code: "MB", name: "Manitoba", gst_rate: "0.05", pst_rate: "0.07")
  end

  test "requires staff for reading and changing rates" do
    get admin_provinces_path
    assert_redirected_to admin_sign_in_path
    patch admin_province_path(@province), params: { province: { gst_rate: "6", pst_rate: "7", hst_rate: "0" } }
    assert_redirected_to admin_sign_in_path
    assert_equal BigDecimal("0.05"), @province.reload.gst_rate
  end

  test "shows rates and saves percentages as decimal fractions" do
    sign_in
    get admin_provinces_path
    assert_response :success
    assert_select "td", "5%"
    get edit_admin_province_path(@province)
    assert_response :success
    assert_select "input[name='province[gst_rate]'][value='5.0']"

    patch admin_province_path(@province), params: {
      province: { gst_rate: "5", pst_rate: "9.975", hst_rate: "0", code: "ON" }
    }
    assert_redirected_to admin_provinces_path
    assert_equal BigDecimal("0.09975"), @province.reload.pst_rate
    assert_equal "MB", @province.code
  end

  test "rejects invalid input without saving any rates" do
    sign_in
    [ "", "abc", "-1", "101", "NaN" ].each do |invalid|
      patch admin_province_path(@province), params: {
        province: { gst_rate: "6", pst_rate: invalid, hst_rate: "0" }
      }
      assert_response :unprocessable_entity
      assert_select "[role='alert']"
      assert_equal BigDecimal("0.05"), @province.reload.gst_rate
      assert_equal BigDecimal("0.07"), @province.pst_rate
    end
  end

  test "new invoices use edited rates while old orders retain their taxes" do
    category = Category.create!(name: "Tax test", slug: "tax-test")
    product = category.products.create!(name: "Pen", description: "Gel pen", price_cents: 1000)
    quantities = { product.id.to_s => 1 }
    details = CheckoutDetails.new(
      name: "Sample Shopper", email: "shopper@example.com", street: "123 Sample Street",
      city: "Winnipeg", postal_code: "R3C 0A1", province: "MB"
    )
    invoice = CheckoutInvoice.new(quantities: quantities, province: @province)
    order = CheckoutOrder.place!(details: details, invoice: invoice)
    sign_in
    patch admin_province_path(@province), params: { province: { gst_rate: "6", pst_rate: "7", hst_rate: "0" } }

    assert_redirected_to admin_provinces_path
    assert_equal 1130, CheckoutInvoice.new(quantities: quantities, province: @province.reload).total_cents
    assert_equal 1120, order.reload.total_cents
    assert_equal BigDecimal("0.05"), order.gst_rate
    assert_equal 50, order.gst_cents
  end

  private

  def sign_in
    admin = Admin.create!(username: "tax-staff", password: "tax-test-password")
    post admin_sign_in_path, params: { admin: { username: admin.username, password: "tax-test-password" } }
  end
end
