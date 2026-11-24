class AdminStorePagesController < AdminBaseController
  before_action :require_admin

  def index
    @pages = StorePage.order(:slug)
  end

  def edit
    @page = StorePage.find(params[:id])
  end

  def update
    @page = StorePage.find(params[:id])
    if @page.update(params.expect(store_page: [ :title, :body, :email, :phone, :opening_hours ]))
      redirect_to admin_store_pages_path, notice: "Page updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
