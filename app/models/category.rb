class Category < ApplicationRecord
has_many :products, dependent: :restrict_with_error
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
end