# frozen_string_literal: true

class GrantsController < ApplicationController
  include WithGrantRoles

  before_action :set_grant, except: %i[index]
  before_action :set_state, only: %i[create edit update]

  # GET /grants
  # GET /grants.json
  def index
    @grants = Grant.by_initiation_date.with_organization.all
    authorize @grants
  end

  # GET /grants/1
  # GET /grants/1.json
  def show
    authorize @grant
  end

  # GET /grants/new
  def new
    @grant = Grant.new
    authorize @grant
  end

  # GET /grants/1/edit
  def edit
    @current_user_role = current_user_grant_permission
    authorize @grant
  end

  # POST /grants
  # POST /grants.json
  def create
    @grant = Grant.new(grant_params)
    authorize @grant
    respond_to do |format|
      if @grant.save
        format.html { redirect_to grant_path(@grant), notice: 'Grant was successfully created.' }
        format.json { render :show, status: :created, location: @grant }
      else
        format.html { render :new }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
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
        format.html { render :edit }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grants/1
  # DELETE /grants/1.json
  def destroy
    authorize @grant
    @grant.destroy
    respond_to do |format|
      format.html { redirect_to grants_url, notice: 'Grant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_grant
    @grant = Grant.with_organization.find(params[:id])
  end

  def set_grant_and_questions
    @grant     = Grant.with_organization.with_questions.find(params[:id])
    @questions = @grant.questions
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def grant_params
    params.require(:grant).permit(
      :name,
      :short_name,
      :state,
      :initiation_date,
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
      :organization_id,
      :draft
    )
  end

  def set_state
    @grant.state = params[:draft].present? ? 'draft' : 'complete'
  end
end
