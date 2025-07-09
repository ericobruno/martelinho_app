class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums
  enum :role, { admin: 0, manager: 1, employee: 2 }

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :active, inclusion: { in: [true, false] }

  # Associations
  has_many :quotes, dependent: :destroy
  has_many :work_orders, dependent: :destroy
  has_many :vehicle_statuses, dependent: :destroy

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_role, ->(role) { where(role: role) }

  # Methods
  def full_name
    name
  end

  def can_manage?
    admin? || manager?
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :account_inactive
  end
end
