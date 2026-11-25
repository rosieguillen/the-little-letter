require "uri"

class Customer < ApplicationRecord
  has_secure_password validations: false
  normalizes :username, with: ->(value) { value.strip.downcase.presence }

  validates :username, presence: true, uniqueness: { case_sensitive: false },
    format: { with: /\A[a-z0-9_]{3,30}\z/, message: "must be 3–30 letters, numbers, or underscores" },
    if: -> { username.present? || password_digest.present? }
  validates :password, presence: true, if: -> { username.present? && password_digest.blank? }
  validates :password, length: { minimum: 12, maximum: 72 }, allow_nil: true
  validates :password, confirmation: true, if: -> { password.present? }
  validates :password_confirmation, presence: true, if: -> { password.present? }

  belongs_to :province
  has_many :orders, dependent: :restrict_with_error

  validates :name, :street, :city, :postal_code, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
