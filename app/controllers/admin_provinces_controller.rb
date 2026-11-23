class AdminProvincesController < AdminBaseController
  before_action :require_admin

  def index
    @provinces = Province.order(:name)
  end

  def edit
    @province = Province.find(params[:id])
  end

  def update
    @province = Province.find(params[:id])
    submitted = params.expect(province: [ :gst_rate, :pst_rate, :hst_rate ])
    rates = {}

    %w[gst_rate pst_rate hst_rate].each do |field|
      percent = BigDecimal(submitted[field].to_s, exception: false)
      if percent.nil? || !percent.finite? || !percent.between?(0, 100)
        @province.errors.add(field, "must be a percentage from 0 to 100")
      else
        rates[field] = percent / 100
      end
    end

    if @province.errors.empty? && @province.update(rates)
      redirect_to admin_provinces_path, notice: "Tax rates updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
