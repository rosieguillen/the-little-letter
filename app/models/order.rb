class Order < ApplicationRecord
  belongs_to :customer

  validates :name, :email, :street, :city, :postal_code, presence: true
  validates :province_code, inclusion: { in: CheckoutDetails::PROVINCE_CODES }
  validates :subtotal_cents, :gst_cents, :pst_cents, :hst_cents, :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :gst_rate, :pst_rate, :hst_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end