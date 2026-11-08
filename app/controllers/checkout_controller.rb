require "digest"
class CheckoutController < ApplicationController
    before_action :require_cart_items, only: [:new, :review, :create]

    def new
        @details = CheckoutDetails.new
    end

    def review
        return unless prepare_invoice

        session[:checkout_details] = invoice_signature
        render :review
    end

    def create
        return unless prepare_invoice

        if session[:checkout_details] != invoice_signature
            session[:checkout_quote] = invoice_signature
            flash.now[:alert] = "Your cart has changed since you last reviewed your order. Please review your order again before placing it."
            render :review. status: :unprocessable_entity
            return
        end

        order = CheckoutOrder.place!(details: checkout_details, invoice: @invoice)
        session.delete(:cart)
        session.delete(:checkout_quote)
        session[:last_order_id] = order.id
        redirect_to checkout_confirmation_path, status: :see_other
    end

    def confirmation
        @order = Order.find_by(id: session[:last_order_id])
        redirect_to root_path unless @order
    end

    private

    def prepare_invoice
    @details = CheckoutDetails.new(checkout_params)

    unless @details.valid?
      render :new, status: :unprocessable_entity
      return false
    end

    province = Province.find_by!(code: @details.province)
    @invoice = CheckoutInvoice.new(quantities: session[:cart], province: province)
    true
  end

  def checkout_params
    params.expect(checkout_details: [:name, :email, :phone, :street, :city, :postal_code, :province])
  end

  def invoice_signature
    province = @invoice.province
    Digest::SHA256.hexdigest([
      checkout_params.to_h,
      @invoice.lines,
      @invoice.taxes,
      [province.gst_rate, province.pst_rate, province.hst_rate]
    ].to_json)
  end


    def require_cart_items
        quantities = session[:cart] || {}
        redirect_to_cart_path unless Product.exists?(id: quantities.keys)
    end
end