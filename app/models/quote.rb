class Quote < ApplicationRecord
  # Money configuration
  monetize :total_amount_cents, allow_nil: true
  monetize :service_value_cents, allow_nil: true

  # Enums
  enum :status, {
    novo: 'novo',
    aberto: 'aberto',
    enviado: 'enviado',
    aprovado: 'aprovado',
    rejeitado: 'rejeitado',
    cancelado: 'cancelado',
    expirado: 'expirado'
  }

  # Validations
  validates :vehicle, presence: true
  validates :user, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :service_value_cents, presence: true, numericality: { greater_than: 0 }
  validate :expires_at_must_be_future, if: :expires_at?

  # Associations
  belongs_to :vehicle
  belongs_to :user
  has_one :customer, through: :vehicle
  has_many :quote_items, dependent: :destroy
  has_many :service_types, through: :quote_items
  has_many :work_orders, dependent: :destroy
  
  # Nested attributes
  accepts_nested_attributes_for :quote_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :vehicle, reject_if: :all_blank

  # Callbacks
  before_save :calculate_total_amount
  before_validation :set_default_status
  before_create :set_expiration_date

  # Scopes
  scope :active, -> { where.not(status: ['expirado', 'rejeitado']) }
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
    (novo? || aberto? || enviado?) && !expired?
  end

  def can_be_converted_to_work_order?
    aprovado? && !expired?
  end

  def formatted_total
    total_amount.format
  end

  def formatted_service_value
    service_value.format
  end

  def approve!
    return false if aprovado? # Não aprovar se já estiver aprovado
    update!(status: 'aprovado', approved_at: Time.current)
  end

  def cancel!
    update!(status: 'cancelado')
  end

  def convert_to_work_order!(converting_user)
    return nil unless can_be_converted_to_work_order?

    # Verificar se já existe uma ordem de serviço para este orçamento
    existing_work_order = work_orders.first
    return existing_work_order if existing_work_order.present?

    # Use transaction to ensure atomic creation
    ActiveRecord::Base.transaction do
      work_order = work_orders.build(
        vehicle: vehicle,
        user: converting_user,
        total_amount: total_amount,
        paid_amount: Money.new(0, 'BRL'),
        status: 'aberta',
        priority: 'normal',
        notes: "Convertido do orçamento ##{id}",
        quote: self
      )

      if work_order.save
        # Create work order items
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
        
        # Reload and save to ensure total is correctly calculated from items
        work_order.reload
        work_order.save!
        work_order
      else
        raise ActiveRecord::Rollback
      end
    end
  rescue => e
    Rails.logger.error "Error converting quote #{id} to work order: #{e.message}"
    nil
  end

  private

  def calculate_total_amount
    if quote_items.any?
      total = quote_items.sum(&:total_price)
      self.total_amount = total
    else
      # If no quote items, use service_value as total_amount
      self.total_amount = service_value if service_value.present? && service_value > 0
    end
    
    # Ensure total_amount is never nil
    self.total_amount = Money.new(0, 'BRL') if total_amount.blank?
  end

  def set_default_status
    self.status = 'novo' if status.blank?
  end

  def set_expiration_date
    self.expires_at = 30.days.from_now if expires_at.blank?
  end

  def expires_at_must_be_future
    return unless expires_at.present?
    
    errors.add(:expires_at, 'deve ser uma data futura') if expires_at <= Time.current
  end
end
