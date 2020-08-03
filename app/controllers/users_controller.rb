# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  skip_after_action :verify_policy_scoped, only: %i[index]

  # GET /users
  # GET /users.json
  def index
    authorize User, :index?
    @q = User.all.ransack(params[:q])
    @q.sorts = 'current_sign_in_at desc' if @q.sorts.empty?
    @pagy, @users = pagy(@q.result, i18n_key: 'activerecord.models.user')
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/1/edit
  def edit; end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path(@user), notice: "#{helpers.full_name(@user)}'s profile has been updated." }
        format.json { render :index, status: :ok }
      else
        flash[:alert] = @user.errors.full_messages
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
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
