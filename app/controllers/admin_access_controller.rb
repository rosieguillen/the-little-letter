class AdminAccessController < ApplicationController
    rate_limit to: 10, within: 3.minutes, only: :create
    before_action :require_admin, only: :show

    def new
    end
    

    def create
            credentials = params.expect(admin: [:username, :password])
        admin = Admin.authenticate_by(
            username: credentials[:username].to_s.strip,
            password: credentials[:password].to_s.strip
        )

        if admin
            reset_session
            session[:admin_id] = admin.id
            redirect_to admin_dashboard_path
        else
            flash.now[:alert] = "The username or password was incorrect."
            render :new, status: :unprocessable_entity
        end
    end

    def show
    end

    def destroy
        reset_session
        redirect_to admin_sign_in_path, status: :see_other
    end

    private 

    def require_admin
        @admin = Admin.find_by(id: session[:admin_id])
        redirect_to admin_sign_in_path unless @admin
    end
end