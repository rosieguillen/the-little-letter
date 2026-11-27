class CustomerOrdersController < ApplicationController
  before_action :require_customer

  def index
    @orders = current_customer.orders.includes(:order_items)
      .order(created_at: :desc, id: :desc).page(params[:page]).per(10)
  end

  private

  def require_customer
    redirect_to customer_sign_in_path unless current_customer
  end
end
