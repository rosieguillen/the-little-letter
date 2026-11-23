class AdminOrdersController < AdminBaseController
  before_action :require_admin

  def index
    @orders = Order.includes(:customer, :order_items)
      .order(created_at: :desc, id: :desc).page(params[:page]).per(10)
  end
end
