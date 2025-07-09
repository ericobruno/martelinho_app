class Vehicle < ApplicationRecord
  # Virtual attributes
  attr_accessor :custom_model_name

  # Validations
  validates :license_plate, presence: true, uniqueness: { case_sensitive: false }
  validates :year, numericality: { 
    greater_than: 1900, 
    less_than_or_equal_to: Date.current.year + 1 
  }, allow_blank: true
  validates :customer, presence: true
  validates :vehicle_brand, presence: true
  validates :vehicle_model, presence: true
  validates :qr_code, uniqueness: true, allow_blank: true

  # Associations
  belongs_to :customer
  belongs_to :vehicle_brand
  belongs_to :vehicle_model
  has_many :quotes, dependent: :destroy
  has_many :work_orders, dependent: :destroy
  has_many :vehicle_statuses, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :customer, reject_if: :all_blank

  # Callbacks
  before_save :normalize_license_plate
  before_create :generate_qr_code
  before_validation :create_custom_model, if: -> { custom_model_name.present? }

  # Scopes
  scope :by_license_plate, ->(plate) { where("license_plate ILIKE ?", "%#{plate}%") }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :by_brand, ->(brand_id) { where(vehicle_brand_id: brand_id) }

  # Methods
  def full_description
    "#{vehicle_brand.name} #{vehicle_model.name} #{year || 'S/A'} - #{license_plate}"
  end

  def current_status
    vehicle_statuses.order(created_at: :desc).first
  end

  def qr_code_image
    return nil unless qr_code.present?
    
    qrcode = RQRCode::QRCode.new(qr_code_url)
    qrcode.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 300,
      border_modules: 4,
      module_px_size: 6
    )
  end

  def qr_code_url
    Rails.application.routes.url_helpers.vehicle_status_url(self, host: Rails.application.config.action_mailer.default_url_options[:host])
  end

  private

  def normalize_license_plate
    self.license_plate = license_plate.upcase.gsub(/[^A-Z0-9]/, '')
  end

  def generate_qr_code
    self.qr_code = SecureRandom.uuid if qr_code.blank?
  end

  def create_custom_model
    return unless custom_model_name.present? && vehicle_brand.present?
    
    model = VehicleModel.find_or_create_by(
      name: custom_model_name,
      vehicle_brand: vehicle_brand
    )
    self.vehicle_model = model
  end
end
