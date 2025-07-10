class WorkOrder < ApplicationRecord
  # Money configuration
  monetize :total_amount_cents, allow_nil: true
  monetize :paid_amount_cents, allow_nil: true

  # Enums
  enum :status, {
    aberta: 'aberta',
    em_andamento: 'em_andamento',
    concluida: 'concluida',
    cancelado: 'cancelado',
    pago: 'pago'
  }

  enum :priority, {
    baixa: 'baixa',
    normal: 'normal',
    alta: 'alta',
    urgente: 'urgente'
  }

  # Validations
  validates :vehicle, presence: true
  validates :user, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :paid_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :completed_at_must_be_after_started_at
  validate :paid_amount_cannot_exceed_total

  # Associations
  belongs_to :vehicle
  belongs_to :user
  belongs_to :quote, optional: true
  has_many :work_order_items, dependent: :destroy
  has_many :service_types, through: :work_order_items
  has_many :vehicle_statuses, dependent: :destroy
  
  # Nested attributes
  accepts_nested_attributes_for :work_order_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :vehicle, reject_if: :all_blank

  # Callbacks
  before_save :calculate_total_amount
  before_save :set_timestamps
  before_save :check_full_payment

  # Scopes
  scope :active, -> { where.not(status: ['concluida', 'cancelado', 'pago']) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_vehicle, ->(vehicle_id) { where(vehicle_id: vehicle_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :overdue, -> { where('created_at < ?', 7.days.ago).where.not(status: ['concluida', 'cancelado', 'pago']) }

  # Methods
  def customer
    vehicle.customer
  end

  def duration
    return nil unless started_at.present? && completed_at.present?
    
    completed_at - started_at
  end

  def formatted_duration
    return 'N/A' unless duration.present?
    
    days = (duration / 1.day).to_i
    hours = ((duration % 1.day) / 1.hour).to_i
    minutes = ((duration % 1.hour) / 1.minute).to_i
    
    parts = []
    parts << "#{days}d" if days > 0
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if minutes > 0
    
    parts.join(' ')
  end

  def formatted_total
    total_amount.format
  end

  def formatted_paid_amount
    paid_amount.format
  end

  def remaining_amount
    total_amount - paid_amount
  end

  def formatted_remaining_amount
    remaining_amount.format
  end

  def payment_percentage
    return 0 if total_amount_cents == 0
    (paid_amount_cents.to_f / total_amount_cents * 100).round(2)
  end

  def fully_paid?
    paid_amount_cents >= total_amount_cents
  end

  def completion_percentage
    return 0 if work_order_items.empty?
    
    completed_items = work_order_items.where(completed: true).count
    (completed_items.to_f / work_order_items.count * 100).round
  end

  def can_be_started?
    aberta?
  end

  def can_be_completed?
    em_andamento? && all_items_completed?
  end

  def can_be_paid?
    concluida? && !fully_paid?
  end

  def start!
    return false unless can_be_started?
    
    update!(status: 'em_andamento', started_at: Time.current)
  end

  def complete!
    return false unless can_be_completed?
    
    update!(status: 'concluida', completed_at: Time.current)
  end

  def mark_as_paid!(amount = nil)
    amount ||= total_amount
    self.paid_amount = amount
    self.status = 'pago' if fully_paid?
    self.fully_paid_at = Time.current if fully_paid? && fully_paid_at.blank?
    save!
  end

  def add_payment!(amount)
    new_paid_amount = paid_amount + Money.new(amount * 100, 'BRL')
    self.paid_amount = new_paid_amount
    self.status = 'pago' if fully_paid?
    self.fully_paid_at = Time.current if fully_paid? && fully_paid_at.blank?
    save!
  end

  def cancel!
    return false if pago?
    
    update!(status: 'cancelado')
  end

  def can_be_finalized?
    concluida? || em_andamento?
  end

  def finalize_and_pay!(payment_amount = nil)
    return false unless can_be_finalized?
    
    # First complete if not already completed
    unless concluida?
      self.status = 'concluida'
      self.completed_at = Time.current if completed_at.blank?
    end
    
    # Handle payment
    if payment_amount.present?
      payment_amount = Money.new(payment_amount.to_f * 100, 'BRL') if payment_amount.is_a?(Numeric)
      self.paid_amount = payment_amount
    else
      # Full payment by default
      self.paid_amount = total_amount
    end
    
    # Update status based on payment
    if fully_paid?
      self.status = 'pago'
      self.fully_paid_at = Time.current if fully_paid_at.blank?
    end
    
    save!
  end

  def current_department
    vehicle_statuses.order(created_at: :desc).first&.department
  end

  # Alias for consistency with view expectations
  def department
    current_department
  end

  private

  def calculate_total_amount
    # Only recalculate if we have work_order_items OR if total_amount is not set
    # This preserves the value when converting from quote before items are created
    if work_order_items.any? || total_amount_cents.blank? || total_amount_cents == 0
      self.total_amount = work_order_items.sum(&:total_price)
    end
  end

  def set_timestamps
    self.started_at = Time.current if status_changed? && em_andamento? && started_at.blank?
    self.completed_at = Time.current if status_changed? && concluida? && completed_at.blank?
  end

  def check_full_payment
    if fully_paid? && !pago? && concluida?
      self.status = 'pago'
      self.fully_paid_at = Time.current if fully_paid_at.blank?
    end
  end

  def completed_at_must_be_after_started_at
    return unless started_at.present? && completed_at.present?
    
    errors.add(:completed_at, 'deve ser posterior ao início') if completed_at <= started_at
  end

  def paid_amount_cannot_exceed_total
    return unless paid_amount_cents.present? && total_amount_cents.present?
    
    errors.add(:paid_amount, 'não pode ser maior que o valor total') if paid_amount_cents > total_amount_cents
  end

  def all_items_completed?
    work_order_items.all?(&:completed?)
  end
end
