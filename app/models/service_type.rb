class ServiceType < ApplicationRecord
  # Money configuration
  monetize :default_price_cents, allow_nil: true

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validates :default_price, presence: true, numericality: { greater_than: 0 }
  validates :active, inclusion: { in: [true, false] }

  # Associations
  has_many :quote_items, dependent: :destroy
  has_many :work_order_items, dependent: :destroy
  has_many :quotes, through: :quote_items
  has_many :work_orders, through: :work_order_items

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }

  # Methods
  def formatted_price
    default_price.format
  end

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end
end
