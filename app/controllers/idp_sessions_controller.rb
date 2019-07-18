# frozen_string_literal: true

# This is here as a passthru for the IDP sign_out.
class IdpSessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    skip_policy_scope
    flash[:success] = 'You have signed out.'
    redirect_to root_path
  end
end