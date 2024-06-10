# frozen_string_literal: true

module GrantReviewers
  class ReviewsController < GrantReviewersController
    before_action :set_grant
    before_action :authorize_grant_editor
    before_action :set_reviewer
    before_action :set_submission, only: %i[create]

    def index
      @current_reviewer_reviews = current_reviewer_reviews

      render :index
    end

    def new
      load_reviewer_data

      @eligible_submissions = set_eligible_submissions
      @review = Review.new(reviewer: @reviewer)
    end

    def create
      @review = Review.new(assigner: current_user, reviewer: @reviewer, submission: @submission)
      respond_to do |format|
        if @review.save
          ReviewerMailer.assignment(review: @review).deliver_now
          reload_reviewer_data
          @reviews = @grant.reviews
          flash.now[:success] = 'Review assigned and notification email sent.'
          format.turbo_stream
        else
          reload_reviewer_data
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @review.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @review = Review.find_by(id: params[:id], reviewer: @reviewer)
      @review.destroy

      if @review.errors.any?
        flash[:alert] = @review.errors.full_messages
        render :index, status: :unprocessable_entity
      else
        reload_reviewer_data
        @reviews = @grant.reviews

        respond_to do |format|
          format.html { redirect_to grant_reviewer_reviews_path(@grant), notice: notice }
          format.turbo_stream
        end
      end
    end

    private

    def set_grant
      @grant = Grant.includes(submissions: %i[submitter applicants], reviews: %i[submission reviewer])
                    .kept
                    .friendly
                    .find(params[:grant_id])
    end

    def set_submission
      @submission = GrantSubmission::Submission.find_by(id: params[:review][:submission_id], grant: @grant)
    end

    def authorize_grant_editor
      authorize @grant, :grant_editor_access?
    end

    def set_reviewer
      @reviewer = User.find(params[:reviewer_id])
    end

    def load_reviewer_data
      set_current_reviewer_submissions
      set_number_of_available_reviews
      set_eligible_submissions
      set_grant_reviewer
    end

    def reload_reviewer_data
      @grant.reload
      load_reviewer_data
    end

    def current_reviewer_reviews
      @grant.reviews.filter { |r| r.reviewer == @reviewer }
    end

    def set_current_reviewer_submissions
      @current_reviewer_submissions = current_reviewer_reviews.map(&:submission)
    end

    def set_number_of_available_reviews
      @number_of_available_reviews = @grant.max_submissions_per_reviewer - @current_reviewer_submissions.length
    end

    def reviewer_may_add_reviews?
      @grant.submissions.any? && @number_of_available_reviews.positive?
    end

    def set_eligible_submissions
      @eligible_submissions = reviewer_may_add_reviews? ? eligible_submissions : nil
    end

    # Find submissions where:
    #  the reviewer is not an applicant; and
    #  the review count < grant maximum reviews per submission
    def eligible_submissions
      available_submissions = GrantSubmission::Submission.by_grant(@grant)
                                                         .submitted
                                                         .includes(:applicants, :reviews)
                                                         .left_outer_joins(:reviews)
                                                         .group('grant_submission_submissions.id')
                                                         .having('COUNT(reviews.id) < ?',
                                                                 @grant.max_reviewers_per_submission)
                                                         .reject { |s| s.applicants.include?(@reviewer) }
      return nil if available_submissions.empty?

      (available_submissions - @current_reviewer_submissions)
    end

    def set_grant_reviewer
      @grant_reviewer = GrantReviewer.find_by(grant: @grant, reviewer: @reviewer)
    end
  end
end
