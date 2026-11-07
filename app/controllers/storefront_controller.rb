class StorefrontController < ApplicationController
  def index
    @categories = Category.order(:name)
    category_slug = params[:slug].presence || params[:category_slug].presence
    @category = Category.find_by!(slug: category_slug) if category_slug
    @keyword = params[:q].to_s.strip

    products = @category ? @category.products : Product.all
    products = products.matching(@keyword) if @keyword.present?
    @products = products.order(:name, :id).page(params[:page]).per(12)

    @filter = params[:filter]
    products = products.where.not(sale_price_cents: nil) if @filter == "sale"
    products = products.where(created_at: 3.days.ago..) if @filter == "new"
  end
end