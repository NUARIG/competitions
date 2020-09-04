class RegisteredUser < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable, :rememberable, :recoverable, :validatable

  after_initialize :set_uid, if: :new_record?

  SAML_DOMAINS = COMPETITIONS_CONFIG[:saml_domains] || []
  RESTRICTED_EMAIL_DOMAINS   = COMPETITIONS_CONFIG[:restricted_domains] || []

  validate  :cannot_register_with_saml_email
  validate  :cannot_register_with_spam_domain

  def cannot_register_with_saml_email
    errors.add(:email, 'Please log in with your institutional ID.') if SAML_DOMAINS.any? { |domain| email&.match? domain }
  end

  def cannot_register_with_spam_domain
    errors.add(:email, 'domain is blocked from registering.') if RESTRICTED_EMAIL_DOMAINS.any? { |domain| email&.match? domain }
  end

  private
  def set_uid
    self.uid = self.email
  end
end