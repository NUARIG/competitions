module Grants
  class SubmissionsController < ApplicationController
    before_action :set_grant
    before_action :set_submission, only: %i[show edit update destroy]
    before_action :set_state, only: %i[edit update]

    # GET /grants/submissions
    # GET /grants/submissions.json
    def index
      authorize @grant, :edit?
      @submissions = Submission.all
    end

    # GET /grants/submissions/1
    # GET /grants/submissions/1.json
    def show
      authorize @submission
    end

    # GET /grants/submissions/new
    def new
      @user = current_user
      @submission = Submission.new(grant: @grant, user: @user)
      authorize @submission
    end

    # GET /grants/submissions/1/edit
    def edit
      authorize @submission
    end

    # POST /grants/submissions
    # POST /grants/submissions.json
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

    # PATCH/PUT /grants/submissions/1
    # PATCH/PUT /grants/submissions/1.json
    def update
      authorize @submission
      respond_to do |format|
        if @submission.update(submission_params)
          format.html { redirect_to grant_submissions_path(@grant), notice: 'Submission was successfully updated.' }
        else
          format.html { render :edit }
        end
      end
    end

    # DELETE /grants/submissions/1
    # DELETE /grants/submissions/1.json
    def destroy
      authorize @submission
      @submission.destroy
      respond_to do |format|
        flash[:notice] = "#{@submission.user.name}'s submission for #{@grant.short_name} was successfully destroyed."
        format.html { redirect_to grant_submissions_path }
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
        :state,
        :award_amount
      )
    end

    def set_state
      @submission.state = params[:draft].present? ? 'draft' : 'complete'
    end

  end
end
