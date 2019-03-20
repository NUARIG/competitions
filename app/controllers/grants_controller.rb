# frozen_string_literal: true

class GrantsController < ApplicationController
  include WithGrantRoles

  before_action :set_grant, except: %i[index new create]
  before_action :set_state, only: %i[edit update]

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
    set_state
    if (@grant.save && save_questions_and_role)
      flash[:notice]  = 'Draft grant was successfully created.'
      flash[:warning] = 'Review Questions below then click "Save and Complete" to finalize.'
      redirect_to grant_questions_url(@grant)
    else
      flash[:alert] = @grant.errors.full_messages
      format.html { render :new }
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
      :default_set,
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

  def save_questions_and_role
    DefaultSet.find(@grant.default_set).questions.ids.each do |q_id|
      new_question = Question.find(q_id).dup
      new_question.update_attribute(:grant_id, @grant.id)
      ConstraintQuestion.where(question_id: q_id).each do |constraint_question|
        constraint_question.dup.update_attribute(:question_id, new_question.id)
      end
    end
    GrantUser.create(grant: @grant, user: current_user, grant_role: 'admin')
  end
end
