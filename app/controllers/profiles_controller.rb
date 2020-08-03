# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_and_authorize_user

  def show
  end

  def update
    if @user.update(user_params)
      flash[:success] = 'Your profile has been updated.'
      render :show
    else
      flash.now[:alert] = @user.errors.full_messages
      render :show
    end
  end

  private

  def set_and_authorize_user
    @user = current_user
    authorize @user, :profile?
  end

  def user_params
    user_params = [:era_commons]
    user_params << %i[system_admin grant_creator] if current_user.system_admin?
    if params[:registered_user]
      user_params << %i[first_name last_name email]
      params.require(:registered_user).permit(user_params)
    elsif params[:saml_user]
      params.require(:saml_user).permit(user_params)
    else
      flash[:alert] = 'Unknown user type.'
      redirect_to :back
    end
  end
end
