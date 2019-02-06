class GrantsController < ApplicationController
  before_action :set_grant, only: %i[show edit update destroy]

  # GET /grants
  # GET /grants.json
  def index
    @grants = Grant.by_initiation_date.with_organization.all
  end

  # GET /grants/1
  # GET /grants/1.json
  def show
  end

  # GET /grants/new
  def new
    @grant = Grant.new
  end

  # GET /grants/1/edit
  def edit
  end

  # POST /grants
  # POST /grants.json
  def create
    @grant = Grant.new(grant_params)

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
    @grant.state = (params[:draft].present?) ? 'draft' : 'complete'

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
    @grant.destroy
    respond_to do |format|
      format.html { redirect_to grants_url, notice: 'Grant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant
      @grant = Grant.with_organization.find(params[:id])
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
        :min_budget,
        :max_budget,
        :applications_per_user,
        :review_guidance,
        :max_reviewers_per_proposal,
        :max_proposals_per_reviewer,
        :panel_date,
        :panel_location,
        :draft)
    end
end
