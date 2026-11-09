
class CheckoutOrder
    def self.place!(details:, invoice:)
        raise ArgumentError, "Cannot place order with empty invoice" if invoice.lines.empty?

        province = invoice.province
        delivery = {
            name: details.name,
            email: details.email,
            phone: details.phone,
            street: details.street,
            city: details.city,
            postal_code: details.postal_code
        }

        Order.transaction do
            customer = Customer.create!(**delivery, province: province)

            order = customer.orders.create!(
                **delivery,
                province_code: province.code,
                subtotal_cents: invoice.subtotal_cents,
                gst_cents: invoice.taxes.fetch("GST", 0),
                pst_cents: invoice.taxes.fetch(province.code == "QC" ? "QST" : "PST", 0),
                hst_cents: invoice.taxes.fetch("HST", 0),
                total_cents: invoice.total_cents,
                gst_rate: province.gst_rate,
                pst_rate: province.pst_rate,
                hst_rate: province.hst_rate
            )

            invoice.lines.each do |line|
                order.order_items.create!(
                    product_id: line.fetch(:product_id),
                    product_name: line.fetch(:name),
                    quantity: line.fetch(:quantity),
                    unit_price_cents: line.fetch(:unit_price_cents)
                )
            end

            order
        end
    end
end
