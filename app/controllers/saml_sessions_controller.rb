# require "ruby-saml"

class SamlSessionsController < Devise::SamlSessionsController
  after_action :set_saml_session_index_on_session, only: :create
  prepend_before_action :store_info_for_sp_initiated_logout, only: :destroy
  prepend_before_action :set_saml_session_index_on_current_user, only: :destroy

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    if resource.sign_in_count == 1
      resource.reviewable_grants.each do |grant|
        flash[:warning] = "You have been added as a reviewer for #{grant.name}"
      end
    end
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  protected

  def set_saml_session_index_on_session
    session[Devise.saml_session_index_key] = current_user.send(Devise.saml_session_index_key) if user_signed_in?
  end

  def set_saml_session_index_on_current_user
    current_user.update({ Devise.saml_session_index_key => session[Devise.saml_session_index_key] })
  end
end
