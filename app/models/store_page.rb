require "uri"

class StorePage < ApplicationRecord
  validates :slug, inclusion: { in: %w[about contact] }, uniqueness: true
  validates :title, :body, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
