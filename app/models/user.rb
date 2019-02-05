class User < ApplicationRecord
  belongs_to :organization

  after_initialize :set_default_organization_role, :if => :new_record?

  enum organization_role: {
  	admin: 	'admin',
  	editor: 'editor',
  	viewer: 'viewer',
  	user: 	'user'
  }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :organization_role, presence: true

  private
	  def set_default_organization_role
	    self.organization_role ||= :user
	  end
end
