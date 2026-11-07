class Product < ApplicationRecord
  belongs_to :category

  has_one_attached :photo do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [240, 420]
    attachable.variant :detail, resize_to_limit: [800, 800]
  end
  validate :acceptable_photo

  validates :name, :description, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }

  validates :sale_price_cents, allow_nil: true,
  numericality: { only_integer: true, greater_than: 0, less_than: :price_cents }

  def self.matching(keyword)
    pattern = "%#{sanitize_sql_like(keyword)}%"
    where("products.name ILIKE :pattern OR products.description ILIKE :pattern", pattern: pattern)
  end

  private

  def acceptable_photo
    return unless photo.attached?
  
    unless photo.blob.content.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:photo, "must be a JPEG, PNG, or WebP image")
    end

    if photo.blob.byte_size > 5.megabytes
      errors.add(:photo, "size must be less than 5MB")
    end
  end
end