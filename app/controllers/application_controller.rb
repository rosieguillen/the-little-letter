class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  helper_method :current_customer

  private

  def current_customer
    @current_customer ||= Customer.where.not(password_digest: nil).find_by(id: session[:customer_id])
  end

  def start_customer_session(customer)
    cart = session[:cart]
    reset_session
    session[:cart] = cart if cart
    session[:customer_id] = customer.id
  end
end
