class RegisteredUser < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :validatable

  SAML_DOMAINS = COMPETITIONS_CONFIG[:app_domain].to_a
  RESTRICTED_EMAIL_DOMAINS   = ['.xyz', '.top', '.website', '.space', '.online']

  validate  :cannot_register_with_northwestern_email
  validate  :cannot_register_with_spam_domain

  def cannot_register_with_northwestern_email
    errors.add(:email, 'Please log in with your institutional ID') if SAML_DOMAINS.any? { |domain| email.match? domain }
  end

  def cannot_register_with_spam_domain
    errors.add(:email, 'domain cannot register.') if RESTRICTED_EMAIL_DOMAINS.any? { |domain| email.match? domain }
  end

  # after_initialize :set_username, if: :new_record?

  # private
  # def set_username
  #   self.username = self.email
  # end
end