class RegisteredUser < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable, :rememberable, :recoverable, :validatable

  after_initialize :set_uid, if: :new_record?
  after_validation :confirm_invited_reviewers, on: :create,
                                               unless: -> { @pending_reviewer_invitations.empty? }

  validate  :cannot_register_with_saml_email
  validate  :cannot_register_with_spam_domain

  def cannot_register_with_saml_email
    errors.add(:email, "\n Please log in with your #{ActionController::Base.helpers.link_to "#{COMPETITIONS_CONFIG[:devise][:saml_authenticatable][:idp_entity_name]}", Rails.application.routes.url_helpers.new_saml_user_session_path}") if User.is_saml_email_address?(email: email)
  end

  def cannot_register_with_spam_domain
    errors.add(:email, 'domain is blocked from registering.') if User.is_restricted_email_address?(email: email)
  end

  def confirm_invited_reviewers
    self.confirmed_at = DateTime.now
  end

  private
  def set_uid
    self.uid = self.email
  end
end
