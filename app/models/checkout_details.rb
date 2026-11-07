require "uri"
class CheckoutDetails
    include ActiveModel::Model

    PROVINCE_CODES = %w[AB BC MB NB NL NS NT NU ON PE QC SK YT].freeze

    attr_accessor :name, :email, :phone, :street, :city, :province, :postal_code

    validates :name, :street, :city, :province, :postal_code, :email, presence: true
    validates :province, inclusion: { in: PROVINCE_CODES }

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end