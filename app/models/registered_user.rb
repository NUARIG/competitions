class RegisteredUser < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable, :rememberable, :recoverable, :validatable

  after_initialize :set_uid, if: :new_record?

  validate  :cannot_register_with_saml_email
  validate  :cannot_register_with_spam_domain

  def cannot_register_with_saml_email
    errors.add(:email, 'Please log in with your institutional ID.') if User.is_saml_email_address?(email: email)
  end

  def cannot_register_with_spam_domain
    errors.add(:email, 'domain is blocked from registering.') if User.is_restricted_email_address?(email: email)
  end

  private
  def set_uid
    self.uid = self.email
  end
end
