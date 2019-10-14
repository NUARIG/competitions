# require "ruby-saml"

class SamlSessionsController < Devise::SamlSessionsController
  after_action :set_user_session_index, only: :create
  skip_before_action :verify_authenticity_token, raise: false
  prepend_before_action :store_info_for_sp_initiated_logout, only: :destroy # FROM BRANCH FOR PR #149
  prepend_before_action :get_user_session_index, only: :destroy

  protected

  def set_user_session_index
    session[:saml_session_index] = current_user.session_index if user_signed_in?
  end

  def get_user_session_index
    current_user.session_index = session[:saml_session_index]
  end

  # THESE TWO METHODS WERE TAKEN FROM THE BRANCH OF DEVISE_SAML_AUTHENTICATABLE IN PR #149.
  # For non transient name ID, save info to identify user for logout purpose
  # before that user's session got destroyed. These info are used in the
  # `after_sign_out_path_for` method below.
  def store_info_for_sp_initiated_logout
    return if Devise.saml_config.name_identifier_format == 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
    @name_identifier_value_for_sp_initiated_logout = current_user.send(Devise.saml_default_user_key)
    @sessionindex_for_sp_initiated_logout = Devise.saml_session_index_key ? current_user.send(Devise.saml_session_index_key) : nil
  end

  # Override devise to send user to IdP logout for SLO
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

  # ORIGINAL FROM THE MASTER DEVISE_SAML_AUTHENTICATABLE GEM.
  # Override devise to send user to IdP logout for SLO
  # def after_sign_out_path_for(_)
  #   idp_entity_id = get_idp_entity_id(params)
  #   request = OneLogin::RubySaml::Logoutrequest.new
  #   request.create(saml_config(idp_entity_id))
  # end


end
