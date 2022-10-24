# frozen_string_literal: true

class GrantsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :store_user_location!, only: :show, unless: :user_signed_in?
  before_action :set_grant, except: %i[index show new create]

  # GET /grants
  # GET /grants.json
  def index
    @q = policy_scope(Grant).ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @pagy, @grants = pagy(@q.result, i18n_key: 'activerecord.models.grant')
  end

  # GET /grants/1
  # GET /grants/1.json
  def show
    @grant = Grant.includes(:contacts).kept.friendly.find(params[:id])

    if authorize @grant
      draft_banner
    end
  end

  # GET /grants/new
  def new
    @grant = Grant.new
    authorize @grant
  end

  # GET /grants/1/edit
  def edit
    if authorize @grant
      draft_banner
    end
  end

  # POST /grants
  # POST /grants.json
  def create
    authorize Grant, :create?
    @grant = Grant.new(grant_params)
    result = GrantServices::New.call(grant: @grant, user: current_user)
    if result.success?
      # TODO: Confirm messages the user should see
      flash[:notice]  = 'Grant saved.'
      flash[:warning] = 'Review the information below then click "Publish this Grant" to finalize.'
      redirect_to grant_grant_permissions_url(@grant)
    else
      flash.now[:alert] = result.messages
      render :new
    end
  end

  # PATCH/PUT /grants/1
  # PATCH/PUT /grants/1.json
  def update
    authorize @grant
    if @grant.update(grant_params)
      flash[:notice] = 'Grant was successfully updated.'
      redirect_back(fallback_location: grant_path(@grant))
    else
      flash.now[:alert] = @grant.errors.full_messages
      render :edit
    end
  end

  # DELETE /grants/1
  # DELETE /grants/1.json
  def destroy
    authorize @grant
    respond_to do |format|
      if @grant.valid?(:discard) && @grant.discard
        format.html { redirect_to grants_url, notice: 'Grant was successfully deleted.' }
      else
        flash[:alert] = @grant.errors.full_messages
        format.html { redirect_back(fallback_location: edit_grant_url(@grant)) }
      end
    end
  end

  private

  def grant_params
    params.require(:grant).permit(
      :name,
      :slug,
      :publish_date,
      :submission_open_date,
      :submission_close_date,
      :rfa,
      :applications_per_user,
      :review_open_date,
      :review_close_date,
      :review_guidance,
      :max_reviewers_per_submission,
      :max_submissions_per_reviewer,
      :panel_date,
      :panel_location,
      criteria_attributes: [
        :id,
        :name,
        :description,
        :is_mandatory,
        :show_comment_field,
        :_destroy]
    )
  end

  def set_grant
    @grant = Grant.kept.friendly.find(params[:id])
  end

  def draft_banner
    flash.now[:warning] = '<strong>Draft Mode</strong> You must publish this grant to make it available to the public.'.html_safe if @grant.draft?
  end
end
