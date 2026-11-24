require "test_helper"

class BreadcrumbsTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Paper Goods", slug: "paper-goods")
    @product = @category.products.create!(name: "Lined Notebook", description: "Ruled pages", price_cents: 1295)
  end

  test "direct product visits show the category hierarchy" do
    get product_path(@product)
    assert_response :success
    assert_select "nav[aria-label='Breadcrumb']" do
      assert_select "ol > li", count: 3
      assert_select "a[href=?]", root_path, text: "Home"
      assert_select "a[href=?]", category_path(@category.slug), text: @category.name
      assert_select "[aria-current='page']", @product.name
    end
  end

  test "category pages show home and the current category" do
    get category_path(@category.slug)
    assert_response :success
    assert_select "nav[aria-label='Breadcrumb']" do
      assert_select "ol > li", count: 2
      assert_select "a[href=?]", root_path, text: "Home"
      assert_select "[aria-current='page']", @category.name
    end
    get root_path
    assert_select "nav[aria-label='Breadcrumb']", count: 0
  end
end
