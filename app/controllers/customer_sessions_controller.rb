class CustomerSessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create

  def new
  end

  def create
    credentials = params.expect(customer: [ :username, :password ])
    customer = Customer.authenticate_by(
      username: credentials[:username].to_s.strip.downcase,
      password: credentials[:password].to_s
    )
    if customer
      start_customer_session(customer)
      redirect_to customer_account_path, status: :see_other
    else
      flash.now[:alert] = "The username or password was incorrect."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    cart = session[:cart]
    reset_session
    session[:cart] = cart if cart
    redirect_to root_path, status: :see_other
  end
end
