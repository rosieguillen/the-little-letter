class AdminBaseController < ApplicationController
  private

  def require_admin
    @admin = Admin.find_by(id: session[:admin_id])
    redirect_to admin_sign_in_path unless @admin
  end
end