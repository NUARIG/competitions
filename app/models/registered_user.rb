class RegisteredUser < User
  # Include devise modules. Others available are:
  # :rememberable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :validatable

  after_initialize :set_uid, if: :new_record?
  after_validation :confirm_invited_reviewers, on: :create,
                                               unless: -> { @pending_reviewer_invitations.empty? }

  validate  :cannot_use_saml_email,   if: -> { User.is_saml_email_address?(email: email) }
  validate  :cannot_use_spam_domain,  if: -> { User.is_restricted_email_address?(email: email) }

  def confirm_invited_reviewers
    self.confirmed_at = DateTime.now
  end

  private

  def set_uid
    self.uid = self.email
  end

  def cannot_use_saml_email
    errors.add(:email, :saml_email_invalid)
    errors.add(:saml_email, "#{ActionController::Base.helpers.link_to "Log in with your #{COMPETITIONS_CONFIG[:devise][:saml_authenticatable][:idp_entity_name]}", Rails.application.routes.url_helpers.new_saml_user_session_path}")
  end

  def cannot_use_spam_domain
    errors.add(:email, 'domain is blocked from registering.')
  end
end