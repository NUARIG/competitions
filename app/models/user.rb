class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to  :organization
  has_many    :grant_users
  has_many    :grants, through: :grant_users


  after_initialize :set_default_organization_role, :if => :new_record?

  ORG_ROLES = { admin:  'admin',
                editor: 'editor',
                viewer: 'viewer',
                none:   'none'
              }.freeze

  enum organization_role: ORG_ROLES, _prefix: true

  validates :organization, presence: true
  validates :organization_role, presence: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  scope :with_organization, -> { includes :organization }

  def name
    "#{first_name} #{last_name}".strip
  end

  private
	  def set_default_organization_role
	    self.organization_role ||= :none
	  end
end
