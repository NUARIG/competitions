class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :organization

  after_initialize :set_default_organization_role, :if => :new_record?

  enum organization_role: {
  	admin: 	'admin',
  	editor: 'editor',
  	viewer: 'viewer',
  	user: 	'user'
  }

  validates :organization, presence: true
  validates :organization_role, presence: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def name
    "#{first_name} #{last_name}".strip
  end

  private
	  def set_default_organization_role
	    self.organization_role ||= :user
	  end
end
