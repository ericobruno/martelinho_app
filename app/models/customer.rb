class Customer < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, presence: true
  validate :valid_cpf_cnpj, if: -> { cpf_cnpj.present? }
  validate :valid_phone_number

  # Associations
  has_many :vehicles, dependent: :destroy
  has_many :quotes, through: :vehicles
  has_many :work_orders, through: :vehicles

  # Callbacks
  before_save :normalize_cpf_cnpj
  before_save :normalize_phone

  # Scopes
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :by_document, ->(doc) { where("cpf_cnpj = ?", doc.gsub(/\D/, '')) }

  # Methods
  def document_type
    return nil if cpf_cnpj.blank?
    cpf_cnpj.gsub(/\D/, '').length == 11 ? 'CPF' : 'CNPJ'
  end

  def formatted_document
    return nil if cpf_cnpj.blank?
    if document_type == 'CPF'
      CPF.new(cpf_cnpj).formatted
    else
      CNPJ.new(cpf_cnpj).formatted
    end
  end

  def formatted_phone
    Phonelib.parse(phone, 'BR').national
  end

  private

  def valid_cpf_cnpj
    return if cpf_cnpj.blank?
    
    clean_doc = cpf_cnpj.gsub(/\D/, '')
    
    # Se após limpeza não sobrou nada, considerar como vazio
    return if clean_doc.blank?
    
    if clean_doc.length == 11
      errors.add(:cpf_cnpj, 'CPF inválido') unless CPF.valid?(clean_doc)
    elsif clean_doc.length == 14
      errors.add(:cpf_cnpj, 'CNPJ inválido') unless CNPJ.valid?(clean_doc)
    else
      errors.add(:cpf_cnpj, 'deve ter 11 dígitos (CPF) ou 14 dígitos (CNPJ)')
    end
  end

  def valid_phone_number
    parsed_phone = Phonelib.parse(phone, 'BR')
    errors.add(:phone, 'número de telefone inválido') unless parsed_phone.valid?
  end

  def normalize_cpf_cnpj
    self.cpf_cnpj = cpf_cnpj.gsub(/\D/, '') if cpf_cnpj.present?
  end

  def normalize_phone
    parsed_phone = Phonelib.parse(phone, 'BR')
    self.phone = parsed_phone.e164 if parsed_phone.valid?
  end
end
