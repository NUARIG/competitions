class RegisteredUsers::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_logged_in_user_to_root, if: -> { saml_user_signed_in? }

  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      # Devise::Confirmable
      # .active_for_authentication? is true for invited reviewers
      if resource.active_for_authentication?
        flash[:notice] = t('devise.registrations.signed_up')
        resource.reviewable_grants.each do |grant|
          flash[:warning] = "You have been added as a reviewer to #{helpers.link_to grant.name, grant_path(grant)}."
        end
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      flash.now[:alert] = resource.errors.full_messages

      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end
end
