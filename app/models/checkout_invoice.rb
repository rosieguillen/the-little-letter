
class CheckoutInvoice
  attr_reader :lines, :subtotal_cents, :taxes, :total_cents, :province

  def initialize(quantities:, province:)
    @province = province
    products = Product.where(id: quantities.keys).order(:name, :id)

    @lines = products.map do |product|
      quantity = quantities.fetch(product.id.to_s)
      unit_price = product.effective_price_cents

      {
        name: product.name,
        product_id: product.id,
        quantity: quantity,
        unit_price_cents: unit_price,
        total_cents: unit_price * quantity
      }
    end

    @subtotal_cents = @lines.sum { |line| line[:total_cents] }

    provincial_label = province.code == "QC" ? "QST" : "PST"
    @taxes = {
      "GST" => province.gst_rate,
      provincial_label => province.pst_rate,
      "HST" => province.hst_rate
    }.select { |_, rate| rate.positive? }
      .transform_values { |rate| (@subtotal_cents * rate).round(0, :half_up).to_i }

    @total_cents = @subtotal_cents + @taxes.values.sum
  end
end
