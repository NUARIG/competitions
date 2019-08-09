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
    params.require(:user).permit(:era_commons)
  end
end
