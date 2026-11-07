
class CheckoutController < ApplicationController
    before_action :require_cart_items

    def new
        @details = CheckoutDetails.new
    end

    def review
        @details = CheckoutDetails.new(checkout_details: [:name, :street, :city, :postal_code, :province, :email, :phone_number])

        if @details.valid?
            render :review
            else
            render :new, status: :unprocessable_entity
        end
    end

    private

    def require_cart_items
        quantities = session[:cart] || {}
        redirect_to_cart_path unless Product.exists?(id: quantities.keys)
    end
end