# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :saml_authenticatable
  # , :trackable

  # belongs_to  :organization
  has_many    :grant_permissions
  has_many    :grants, through: :grant_permissions

  # before_validation :set_organization, if: :new_record?
  after_initialize :set_default_organization_role, if: :new_record?

  ORG_ROLES = { admin: 'admin',
                none: 'none' }.freeze

  enum organization_role: ORG_ROLES, _prefix: true

  # validates :organization, presence: true
  validates :organization_role, presence: true
  validates :email, presence: true, uniqueness: true
  # validates :first_name, presence: true
  # validates :last_name, presence: true

  scope :with_organization, -> { includes :organization }

  def name
    "#{first_name} #{last_name}".strip
  end

  private

  # TODO: This section still needs to be sorted out to create Organizations on the fly from emails.
  # def parse_organization_from_email
  #   byebug
  #   url_fragment = self.email.split('@')[1]
  #   url = "https://www.#{url_fragment}"
  #   organization_name = url_fragment.split('.')[0]
  #   organization = Organization.first_or_create(name: organization_name, url: url, slug: organization_name)
  #   # TODO: Add error handling for an email error.
  # end

  # def set_organization
  #   byebug
  #   self.organization = parse_organization_from_email
  # end

  def set_default_organization_role
    self.organization_role ||= :none
  end

end
