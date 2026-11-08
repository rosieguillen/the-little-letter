class CartController < ApplicationController
  def show
    @quantities = session[:cart] || {}
    @products = Product.where(id: @quantities.keys).order(:name, :id)

    @subtotal_cents = @products.sum do |product|
      product.effective_price_cents * @quantities.fetch(product.id.to_s)
    end
  end

  def add
    product = Product.find(params[:product_id])
    cart = session[:cart] || {}
    key = product.id.to_s

    if !cart.key?(key) && cart.size >= 30
      redirect_to cart_path, alert: "Your cart can hold up to 30 different products.",
        status: :see_other
      return
    end

    cart[key] = [cart.fetch(key, 0) + 1, 99].min
    session[:cart] = cart
    redirect_to cart_path, status: :see_other
  end

  def update
  cart = session[:cart] || {}
  key = params[:product_id].to_s
  quantity = Integer(params[:quantity].to_s, 10, exception: false)

  unless cart.key?(key) && quantity&.between?(1, 99)
    redirect_to cart_path, alert: "Invalid quantity.", status: :see_other
    return
  end

    cart[key] = quantity
    session[:cart] = cart
    redirect_to cart_path, status: :see_other
  end

  def remove
    cart = session[:cart] || {}
    cart.delete(params[:product_id].to_s)
    session[:cart] = cart
    redirect_to cart_path, status: :see_other
  end

end