class VehicleModel < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Validations
  validates :name, presence: true
  validates :slug, presence: true
  validates :vehicle_brand, presence: true
  validates :name, uniqueness: { scope: :vehicle_brand_id }

  # Associations
  belongs_to :vehicle_brand
  has_many :vehicles, dependent: :destroy

  # Scopes
  scope :by_brand, ->(brand_id) { where(vehicle_brand_id: brand_id) }
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }

  # Methods
  def full_name
    "#{vehicle_brand.name} #{name}"
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def normalize_friendly_id(text)
    text.to_s.parameterize
  end
end
