class AdminCategoriesController < AdminBaseController
  before_action :require_admin

        def index
            @categories = Category.order(:name)
            @category = Category.new
        end

        def create
            @category = Category.new(parmams.expect(category: [ :name ]))
            @category.slug = @category.name.to_s.parameterize

            if @category.save
                redirect_to admin_categories_path, status: :see_other
            else
                @categories = Category.order(:name)
                render :index, status: :unprocessable_entity
            end
        end

        def edit
            @category = Category.find(params[:id])
        end

        def update
            @category = Category.find(params[:id])

            if @category.update(params.require(:category).permit(:name))
                redirect_to admin_categories_path, status: :see_other
            else
                render :edit, status: :unprocessable_entity
            end
        end
end
