class Department < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validates :active, inclusion: { in: [true, false] }

  # Associations
  has_many :vehicle_statuses, dependent: :destroy
  has_many :vehicles, through: :vehicle_statuses

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }

  # Methods
  def current_vehicles
    vehicles.joins(:vehicle_statuses)
            .where(vehicle_statuses: { department: self, exited_at: nil })
            .distinct
  end

  def current_vehicles_count
    current_vehicles.count
  end

  def average_processing_time
    completed_statuses = vehicle_statuses.where.not(exited_at: nil)
    return 0 if completed_statuses.empty?

    total_time = completed_statuses.sum { |status| status.exited_at - status.entered_at }
    total_time / completed_statuses.count
  end

  def formatted_average_processing_time
    time = average_processing_time
    return 'N/A' if time.zero?

    days = (time / 1.day).to_i
    hours = ((time % 1.day) / 1.hour).to_i
    minutes = ((time % 1.hour) / 1.minute).to_i

    parts = []
    parts << "#{days}d" if days > 0
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if minutes > 0

    parts.join(' ')
  end

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end
end
