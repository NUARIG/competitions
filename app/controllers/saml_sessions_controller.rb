# require "ruby-saml"

class SamlSessionsController < Devise::SamlSessionsController
  after_action :set_saml_session_index_on_session, only: :create
  skip_before_action :verify_authenticity_token, raise: false
  prepend_before_action :store_info_for_sp_initiated_logout, only: :destroy # FROM BRANCH FOR PR #149
  prepend_before_action :set_saml_session_index_on_current_user, only: :destroy

  protected

  def set_saml_session_index_on_session
    session[Devise.saml_session_index_key] = current_user.send(Devise.saml_session_index_key) if user_signed_in?
  end

  def set_saml_session_index_on_current_user
    current_user.update_attribute(Devise.saml_session_index_key, session[Devise.saml_session_index_key])
  end

  # THESE FOLLOWING TWO METHODS WERE TAKEN FROM THE BRANCH OF DEVISE_SAML_AUTHENTICATABLE IN PR #149.
  # https://github.com/apokalipto/devise_saml_authenticatable/pull/149
  # For non transient name ID, save info to identify user for logout purpose
  # before that user's session got destroyed. These info are used in the
  # `after_sign_out_path_for` method below.
  def store_info_for_sp_initiated_logout
    return if Devise.saml_config.name_identifier_format == 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
    @name_identifier_value_for_sp_initiated_logout = current_user.send(Devise.saml_default_user_key)
    @sessionindex_for_sp_initiated_logout = Devise.saml_session_index_key ? current_user.send(Devise.saml_session_index_key) : nil
  end

  # Override devise to send user to IdP logout for SLO
  # PREVIOUS VERSION CAN BE FOUND HERE:
  # https://github.com/apokalipto/devise_saml_authenticatable/blob/4760cd3e72b5f4bacd9746a8fd33b2a3c447a9ec/app/controllers/devise/saml_sessions_controller.rb
  def after_sign_out_path_for(_)
    idp_entity_id = get_idp_entity_id(params)
    request = OneLogin::RubySaml::Logoutrequest.new
    saml_settings = saml_config(idp_entity_id)

    # Add attributes to saml_settings which will later be used to create the SP
    # initiated logout request
    unless Devise.saml_config.name_identifier_format == 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
      saml_settings.name_identifier_value = @name_identifier_value_for_sp_initiated_logout
      saml_settings.sessionindex = @sessionindex_for_sp_initiated_logout
      @name_identifier_value_for_sp_initiated_logout = nil
      @sessionindex_for_sp_initiated_logout = nil
    end

    request.create(saml_settings)
  end
end
