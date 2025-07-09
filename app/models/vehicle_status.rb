class VehicleStatus < ApplicationRecord
  # Enums
  enum :status, {
    entered: 'entered',
    in_progress: 'in_progress',
    completed: 'completed',
    waiting: 'waiting',
    exited: 'exited'
  }

  # Validations
  validates :vehicle, presence: true
  validates :department, presence: true
  validates :work_order, presence: true
  validates :user, presence: true
  validates :status, presence: true
  validates :entered_at, presence: true
  validate :exited_at_must_be_after_entered_at

  # Associations
  belongs_to :vehicle
  belongs_to :department
  belongs_to :work_order
  belongs_to :user

  # Callbacks
  before_create :set_entered_at
  after_update :create_next_status, if: :saved_change_to_exited_at?

  # Scopes
  scope :current, -> { where(exited_at: nil) }
  scope :completed, -> { where.not(exited_at: nil) }
  scope :by_department, ->(department_id) { where(department_id: department_id) }
  scope :by_vehicle, ->(vehicle_id) { where(vehicle_id: vehicle_id) }
  scope :by_work_order, ->(work_order_id) { where(work_order_id: work_order_id) }

  # Methods
  def duration
    return nil unless entered_at.present?
    
    end_time = exited_at || Time.current
    end_time - entered_at
  end

  def formatted_duration
    time = duration
    return 'N/A' unless time.present?

    days = (time / 1.day).to_i
    hours = ((time % 1.day) / 1.hour).to_i
    minutes = ((time % 1.hour) / 1.minute).to_i

    parts = []
    parts << "#{days}d" if days > 0
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if minutes > 0

    parts.join(' ')
  end

  def current?
    exited_at.nil?
  end

  def completed?
    exited_at.present?
  end

  def exit!(exiting_user, notes = nil)
    return false if completed?
    
    update!(
      exited_at: Time.current,
      status: 'exited',
      notes: [self.notes, notes].compact.join("\n")
    )
  end

  def self.track_vehicle_entry(vehicle, department, work_order, user, notes = nil)
    # Exit from current department if exists
    current_status = vehicle.vehicle_statuses.current.first
    current_status&.exit!(user, "Saiu automaticamente para #{department.name}")

    # Create new status entry
    create!(
      vehicle: vehicle,
      department: department,
      work_order: work_order,
      user: user,
      status: 'entered',
      entered_at: Time.current,
      notes: notes
    )
  end

  private

  def set_entered_at
    self.entered_at = Time.current if entered_at.blank?
  end

  def exited_at_must_be_after_entered_at
    return unless entered_at.present? && exited_at.present?
    
    errors.add(:exited_at, 'deve ser posterior à entrada') if exited_at <= entered_at
  end

  def create_next_status
    # This could be extended to automatically move to next department
    # based on work order workflow
  end
end
