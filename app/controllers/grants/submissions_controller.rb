module Grants
  class SubmissionsController < ApplicationController
    before_action :set_grant
    before_action :set_submission, only: %i[show edit update destroy]

    # GET /grants/[grant_id]/submissions
    # GET /grants/[grant_id]/submissions.json
    def index
      authorize @grant, :grant_viewer_access?
      @submissions = Submission.where(grant: @grant)
    end

    # GET /grants/[grant_id]/submissions/1
    # GET /grants/[grant_id]/submissions/1.json
    def show
      authorize @submission
    end

    # GET /grants/[grant_id]/submissions/new
    def new
      @user = current_user
      @submission = Submission.new(grant: @grant, user: @user)
      authorize @submission
    end

    # GET /grants/[grant_id]/submissions/1/edit
    def edit
      authorize @submission
    end

    # POST /grants/[grant_id]/submissions
    # POST /grants/[grant_id]/submissions.json
    def create
      @submission = Submission.new(submission_params)
      set_state
      @submission.user = current_user
      @submission.grant = @grant
      authorize @submission
      respond_to do |format|
        if @submission.save
          flash[:notice] = "#{@submission.user.name}'s submission for #{@grant.short_name} was created."
          format.html { redirect_to grant_submission_path(@grant, @submission) }
        else
          flash[:alert] = @submission.errors.full_messages
          format.html { render :new }
        end
      end
    end

    # PATCH/PUT /grants/[grant_id]/submissions/1
    # PATCH/PUT /grants/[grant_id]/submissions/1.json
    def update
      authorize @submission
      set_state
      respond_to do |format|
        if @submission.update(submission_params)
          format.html { redirect_to grant_submission_path(@grant, @submission), notice: 'Submission was successfully updated.' }
        else
          flash[:alert] = @submission.errors.full_messages
          format.html { render :edit }
        end
      end
    end

    # DELETE /grants/[grant_id]/submissions/1
    # DELETE /grants/[grant_id]/submissions/1.json
    def destroy
      authorize @submission
      @submission.destroy
      respond_to do |format|
        flash[:notice] = "#{@submission.user.name}'s submission for #{@grant.short_name} was successfully destroyed."
        format.html { redirect_to grant_path(@grant) }
      end
    end

    private

    def set_grant
      @grant = Grant.find(params[:grant_id])
    end

    def set_submission
      @submission = Submission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(
        :grant_id,
        :user_id,
        :project_title,
        :award_amount
      )
    end

    def set_state
      @submission.state = params[:draft].present? ? 'draft' : 'submitted'
    end

  end
end
