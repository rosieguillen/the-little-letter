class StorefrontController < ApplicationController
  def index
    @categories = Category.order(:name)
    @category = Category.find_by!(slug: params[:slug]) if params[:slug].present?

    products = @category ? @category.products : Product.all
    @products = products.order(:name)

  end
end