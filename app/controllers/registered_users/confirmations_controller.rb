# frozen_string_literal: true

class RegisteredUsers::ConfirmationsController < Devise::ConfirmationsController
  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    else
      flash.now[:alert] = resource.errors.full_messages
      respond_with(resource)
    end
  end
end
