class Product < ApplicationRecord
  belongs_to :category

  validates :name, :description, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }

  def self.matching(keyword)
    pattern = "%#{sanitize_sql_like(keyword)}%"
    where("products.name ILIKE :pattern OR products.description ILIKE :pattern", pattern: pattern)
  end
end