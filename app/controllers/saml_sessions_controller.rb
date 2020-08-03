# require "ruby-saml"

class SamlSessionsController < Devise::SamlSessionsController
  after_action :set_saml_session_index_on_session, only: :create
  # skip_before_action :verify_authenticity_token, raise: false
  prepend_before_action :store_info_for_sp_initiated_logout, only: :destroy
  prepend_before_action :set_saml_session_index_on_current_user, only: :destroy

  protected

  def set_saml_session_index_on_session
    session[Devise.saml_session_index_key] = current_user.send(Devise.saml_session_index_key) if user_signed_in?
  end

  def set_saml_session_index_on_current_user
    current_user.update_attribute(Devise.saml_session_index_key, session[Devise.saml_session_index_key])
  end
end
