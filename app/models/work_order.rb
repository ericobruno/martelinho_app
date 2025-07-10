class WorkOrder < ApplicationRecord
  # Money configuration
  monetize :total_amount_cents, allow_nil: true
  monetize :paid_amount_cents, allow_nil: true

  # Enums
  enum :status, {
    pending: 'pending',
    in_progress: 'in_progress',
    completed: 'completed',
    cancelled: 'cancelled',
    on_hold: 'on_hold',
    aberta: 'aberta'
  }

  enum :priority, {
    low: 'low',
    normal: 'normal',
    high: 'high',
    urgent: 'urgent'
  }

  # Validations
  validates :vehicle, presence: true
  validates :user, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :description, length: { maximum: 1000 }
  validate :completed_at_must_be_after_started_at

  # Associations
  belongs_to :vehicle
  belongs_to :user
  belongs_to :quote, optional: true
  belongs_to :department, optional: true
  has_many :work_order_items, dependent: :destroy
  has_many :service_types, through: :work_order_items
  has_many :vehicle_statuses, dependent: :destroy
  
  # Nested attributes
  accepts_nested_attributes_for :work_order_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :vehicle, reject_if: :all_blank

  # Callbacks
  before_save :calculate_total_amount
  before_save :set_timestamps

  # Scopes
  scope :active, -> { where.not(status: ['completed', 'cancelled']) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_vehicle, ->(vehicle_id) { where(vehicle_id: vehicle_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :overdue, -> { where('created_at < ?', 7.days.ago).where.not(status: ['completed', 'cancelled']) }

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

  def total_price_cents
    total_amount_cents
  end

  def paid_amount
    paid_amount_cents / 100.0 if paid_amount_cents.present?
  end

  def completion_percentage
    return 0 if work_order_items.empty?
    
    completed_items = work_order_items.where(completed: true).count
    (completed_items.to_f / work_order_items.count * 100).round
  end

  def can_be_started?
    pending?
  end

  def can_be_completed?
    in_progress? && all_items_completed?
  end

  def start!
    return false unless can_be_started?
    
    update!(status: 'in_progress', started_at: Time.current)
  end

  def complete!
    return false unless can_be_completed?
    
    update!(status: 'completed', completed_at: Time.current)
  end

  def cancel!
    return false if completed?
    
    update!(status: 'cancelled')
  end

  def current_department
    vehicle_statuses.order(created_at: :desc).first&.department
  end

  private

  def calculate_total_amount
    self.total_amount = work_order_items.sum(&:total_price)
  end

  def set_timestamps
    self.started_at = Time.current if status_changed? && in_progress? && started_at.blank?
    self.completed_at = Time.current if status_changed? && completed? && completed_at.blank?
  end

  def completed_at_must_be_after_started_at
    return unless started_at.present? && completed_at.present?
    
    errors.add(:completed_at, 'deve ser posterior ao início') if completed_at <= started_at
  end

  def all_items_completed?
    work_order_items.all?(&:completed?)
  end
end
