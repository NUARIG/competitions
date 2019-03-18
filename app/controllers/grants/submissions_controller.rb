module Grants
  class SubmissionsController < ApplicationControlle
    before_action :set_grant
    before_action :set_submission, only: %i[show edit update destroy]
    before_action :set_state, only: %i[create edit update]

    # GET /grants/submissions
    # GET /grants/submissions.json
    def index
      authorize @grant, :edit?
      @submissions = Submission.by_creation_time.where(grant: @grant).all
    end

    # GET /grants/submissions/1
    # GET /grants/submissions/1.json
    def show
      authorize @submission
    end

    # GET /grants/submissions/new
    def new
      @submission = Submission.new
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
      authorize @submission
      respond_to do |format|
        if @grant_user.save
          flash[:notice] = "#{@submission.user.name}'s submission for #{@grant.short_name} was created."
          format.html { redirect_to grant_submission_path(@grant) }
          format.json { render :show, status: :created, location: @submission }
        else
          flash[:alert] = @submission.errors.full_messages
          format.html { render :new }
          format.json { render json: @submission.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /grants/submissions/1
    # PATCH/PUT /grants/submissions/1.json
    def update
      authorize @submission
      respond_to do |format|
        if @submission.update(grant_params)
          format.html { redirect_to grant_submission_path(@grant), notice: 'Submission was successfully updated.' }
          format.json { render :show, status: :ok, location: @submission }
        else
          format.html { render :edit }
          format.json { render json: @submission.errors, status: :unprocessable_entity }
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
        format.html { redirect_to grant_path }
        format.json { head :no_content }
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
        :project_title
        :state
        :award_amount
      )
    end

    def set_state
      @submission.state = params[:draft].present? ? 'draft' : 'complete'
    end

  end
end
