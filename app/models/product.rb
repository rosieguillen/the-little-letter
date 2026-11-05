class Product < ApplicationRecord
  belongs_to :category

  validates :name, :description, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
end