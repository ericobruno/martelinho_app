class Quote < ApplicationRecord
  # Money configuration
  monetize :total_amount_cents, allow_nil: true

  # Enums
  enum :status, {
    draft: 'draft',
    sent: 'sent',
    approved: 'approved',
    rejected: 'rejected',
    expired: 'expired'
  }

  # Validations
  validates :vehicle, presence: true
  validates :user, presence: true
  validates :status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :expires_at_must_be_future, if: :expires_at?

  # Associations
  belongs_to :vehicle
  belongs_to :user
  has_many :quote_items, dependent: :destroy
  has_many :service_types, through: :quote_items
  has_many :work_orders, dependent: :destroy
  
  # Nested attributes
  accepts_nested_attributes_for :quote_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :vehicle, reject_if: :all_blank

  # Callbacks
  before_save :calculate_total_amount
  before_create :set_default_status
  before_create :set_expiration_date

  # Scopes
  scope :active, -> { where.not(status: ['expired', 'rejected']) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_vehicle, ->(vehicle_id) { where(vehicle_id: vehicle_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # Methods
  def customer
    vehicle.customer
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def can_be_approved?
    sent? && !expired?
  end

  def can_be_converted_to_work_order?
    approved? && !expired?
  end

  def formatted_total
    total_amount.format
  end

  def convert_to_work_order!(converting_user)
    return nil unless can_be_converted_to_work_order?

    work_order = work_orders.build(
      vehicle: vehicle,
      user: converting_user,
      total_amount: total_amount,
      status: 'pending',
      priority: 'normal',
      notes: "Convertido do orçamento ##{id}"
    )

    if work_order.save
      quote_items.each do |quote_item|
        work_order.work_order_items.create!(
          service_type: quote_item.service_type,
          quantity: quote_item.quantity,
          unit_price: quote_item.unit_price,
          total_price: quote_item.total_price,
          description: quote_item.description,
          completed: false
        )
      end
      work_order
    else
      nil
    end
  end

  private

  def calculate_total_amount
    total = quote_items.sum(&:total_price)
    self.total_amount = total
  end

  def set_default_status
    self.status = 'draft' if status.blank?
  end

  def set_expiration_date
    self.expires_at = 30.days.from_now if expires_at.blank?
  end

  def expires_at_must_be_future
    return unless expires_at.present?
    
    errors.add(:expires_at, 'deve ser uma data futura') if expires_at <= Time.current
  end
end
