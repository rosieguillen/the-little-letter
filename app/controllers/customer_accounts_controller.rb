class CustomerAccountsController < ApplicationController
  before_action :require_customer, only: [ :edit, :update ]

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(params.expect(customer: [
      :username, :password, :password_confirmation, :name, :email, :phone,
      :street, :city, :postal_code, :province_id
    ]))
    @customer.errors.add(:username, "can't be blank") if @customer.username.blank?
    if @customer.username.present? && @customer.save
      start_customer_session(@customer)
      redirect_to customer_account_path, notice: "Your account is ready.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @customer.errors.add(:username, "has already been taken")
    render :new, status: :unprocessable_entity
  end

  def edit
    @customer = current_customer
  end

  def update
    @customer = current_customer
    if @customer.update(params.expect(customer: [ :name, :email, :phone, :street, :city, :postal_code, :province_id ]))
      redirect_to customer_account_path, notice: "Delivery details saved.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_customer
    redirect_to customer_sign_in_path unless current_customer
  end
end
