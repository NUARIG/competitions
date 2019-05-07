# frozen_string_literal: true

class GrantsController < ApplicationController
  include WithGrantRoles

  before_action :set_grant,    except: %i[index new create]

  # GET /grants
  # GET /grants.json
  def index
    @grants = Grant.not_deleted.by_publish_date.with_organization
    authorize @grants
  end

  # GET /grants/1
  # GET /grants/1.json
  def show
    if authorize @grant
      draft_banner
    end
    @grant = GrantDecorator.new(@grant)
  end

  # GET /grants/new
  def new
    @grant = Grant.new
    authorize @grant
  end

  # GET /grants/1/edit
  def edit
    @current_user_role = current_user_grant_permission
    if authorize @grant
      draft_banner
    end
  end

  # POST /grants
  # POST /grants.json
  def create
    authorize Grant, :create?
    @grant = Grant.new(grant_params)
    @grant.organization_id = current_user.organization_id
    result = GrantServices::New.call(grant: @grant, user: current_user)
    if result.success?
      # TODO: Confirm messages the user should see
      flash[:notice]  = 'Grant saved.'
      flash[:warning] = 'Review the information below then click "Publish this Grant" to finalize.'
      redirect_to grant_grant_users_url(@grant)
    else
      respond_to do |format|
        flash[:alert] = result.messages
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /grants/1
  # PATCH/PUT /grants/1.json
  def update
    authorize @grant
    respond_to do |format|
      if @grant.update(grant_params)
        format.html { redirect_to grant_path(@grant), notice: 'Grant was successfully updated.' }
        format.json { render :show, status: :ok, location: @grant }
      else
        flash[:alert] = @grant.errors.full_messages
        format.html { render :edit }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grants/1
  # DELETE /grants/1.json
  def destroy
    authorize @grant
    #@grant.soft_delete! # calling concern method
    result = GrantServices::SoftDelete.call(grant: @grant)
    respond_to do |format|
      if result.success?
        format.html { redirect_to grants_url, notice: 'Grant was successfully deleted.' }
      else
        flash[:alert] = result.message
        format.html { redirect_back(fallback_location: edit_grant_url(@grant)) }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
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
      :max_reviewers_per_proposal,
      :max_proposals_per_reviewer,
      :panel_date,
      :panel_location,
    )
  end

  def set_grant
    @grant = Grant.with_organization.friendly.find(params[:id])
  end

  def draft_banner
    flash[:warning] = '<strong>Draft warning</strong>'.html_safe if @grant.draft?
  end
end
