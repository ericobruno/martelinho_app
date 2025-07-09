class VehicleBrand < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  # Associations
  has_many :vehicle_models, dependent: :destroy
  has_many :vehicles, dependent: :destroy

  # Scopes
  scope :active, -> { joins(:vehicle_models).where(vehicle_models: { id: VehicleModel.select(:id) }).distinct }
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }

  # Methods
  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def normalize_friendly_id(text)
    text.to_s.parameterize
  end
end
