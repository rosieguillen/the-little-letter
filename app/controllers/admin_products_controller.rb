class AdminProductsController < AdminBaseController
  before_action :require_admin

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_dashboard_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  @product = Product.find(params[:id])
end

def update
  @product = Product.find(params[:id])

  if @product.update(product_params)
    redirect_to admin_dashboard_path, status: :see_other
  else
    render :edit, status: :unprocessable_entity
  end
end

def destroy
  product = Product.find(params[:id])
  product.destroy!
  redirect_to admin_dashboard_path, status: :see_other
end

  private

  def product_params
    params.expect(product: [:name, :description, :category_id, :price_cents, :sale_price_cents])
  end
end