require "uri"

class Customer < ApplicationRecord
  belongs_to :province
  has_many :orders, dependent: :restrict_with_error

  validates :name, :street, :city, :postal_code, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end