# require "ruby-saml"

class SamlSessionsController < Devise::SamlSessionsController
  after_action :set_user_session_index, only: :create
  skip_before_action :verify_authenticity_token, raise: false
  prepend_before_action :store_info_for_sp_initiated_logout, only: :destroy
  prepend_before_action :get_user_session_index, only: :destroy

  protected

  def set_user_session_index
    session[:saml_session_index] = current_user.session_index if user_signed_in?
  end

  def get_user_session_index
    current_user.session_index = session[:saml_session_index]
  end
end
