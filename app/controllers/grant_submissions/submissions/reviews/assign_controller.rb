module GrantSubmissions
  module Submissions
    module Reviews
      class AssignController < ReviewsController
        before_action :set_grant
        before_action :authorize_grant_editor
        before_action :set_submission

        def new
          if @grant == @submission.grant
            set_number_of_available_reviews
            @eligible_reviewers = @submission.eligible_reviewers
            @review = Review.new(submission: @submission)
          else
            flash[:alert] = 'Submission is not valid or could not be located'
            redirect_to grant_submissions_path(@grant)
          end
        end

        def create
          @reviewer = @grant.reviewers.find { |reviewer| reviewer.id == params[:review][:reviewer_id].to_i }
          @review = Review.new(submission: @submission, assigner: current_user, reviewer: @reviewer)
          set_user_grant_role

          respond_to do |format|
            if @review.save
              ReviewerMailer.assignment(review: @review).deliver_now
              set_number_of_available_reviews
              @eligible_reviewers = @submission.reload.eligible_reviewers

              flash.now[:success] =
                "Submission assigned for review. A notification email was sent to #{helpers.full_name(@review.reviewer)}."
              format.turbo_stream
            else
              @submission.reviews.reload

              set_number_of_available_reviews
              @eligible_reviewers = @submission.eligible_reviewers
              format.html { render :new, status: :unprocessable_entity }
              format.json { render json: @review.errors, status: :unprocessable_entity }
            end
          end
        end

        private

        def set_grant
          @grant = Grant.includes(grant_reviewers: :reviewer).friendly.find(params[:grant_id])
        end

        def authorize_grant_editor
          authorize @grant, :grant_editor_access?
        end

        def set_user_grant_role
          @user_grant_role = current_user.get_role_by_grant(grant: @grant)
        end

        def set_submission
          @submission = GrantSubmission::Submission.includes(:reviewers).find(params[:submission_id])
        end

        def set_eligible_reviewers
          return nil if grant.reviewers.none? || @number_of_available_reviews == 0

          @submission.eligible_reviewers
        end

        def set_number_of_available_reviews
          @number_of_available_reviews = @grant.max_reviewers_per_submission - @submission.reviews.length
        end
      end
    end
  end
end
