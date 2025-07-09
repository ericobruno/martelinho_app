class QuoteItem < ApplicationRecord
  # Money configuration
  monetize :unit_price_cents, allow_nil: true
  monetize :total_price_cents, allow_nil: true

  # Validations
  validates :quote, presence: true
  validates :service_type, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  # Associations
  belongs_to :quote
  belongs_to :service_type

  # Callbacks
  before_save :calculate_total_price
  before_save :set_unit_price_from_service_type, if: :unit_price_blank?
  after_save :update_quote_total
  after_destroy :update_quote_total

  # Methods
  def formatted_unit_price
    unit_price.format
  end

  def formatted_total_price
    total_price.format
  end

  def service_name
    service_type.name
  end

  private

  def calculate_total_price
    self.total_price = unit_price * quantity
  end

  def set_unit_price_from_service_type
    self.unit_price = service_type.default_price
  end

  def unit_price_blank?
    unit_price.blank? || unit_price.zero?
  end

  def update_quote_total
    quote.save! if quote.persisted?
  end
end
