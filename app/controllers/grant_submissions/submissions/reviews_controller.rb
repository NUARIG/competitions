module GrantSubmissions
  module Submissions
    class ReviewsController < ApplicationController
      before_action     :set_review_grant_and_submission, only: %i[show edit update destroy]
      skip_after_action :verify_policy_scoped, only: %i[index]

      # GET /reviews
      # GET /reviews.json
      def index
        @grant = Grant.kept.with_criteria.friendly.find(params[:grant_id])
        authorize @grant, :grant_viewer_access?
        @submission     = GrantSubmission::Submission.includes(:applicant).find(params[:submission_id])
        @q              = Review.with_reviewer.with_criteria_reviews.by_submission(@submission).ransack(params[:q])
        @q.sorts        = ['reviewer_last_name asc', 'overall_impact_score desc'] if @q.sorts.empty?
        @pagy, @reviews = pagy(@q.result, i18n_key: 'activerecord.models.review')
        respond_to do |format|
          format.html { render :index }
          format.pdf  { render pdf:                     "reviews_#{@submission.applicant.last_name}_#{@submission.title.truncate_words(3, separator: '-')}",
                               # disposition:             'attachment',
                               template:                'grant_submissions/submissions/reviews/index.html.haml',
                               layout:                  'pdf.html.haml',
                               disable_internal_links:  true,
                               disable_external_links:  true,
                               print_media_type:        true,
                               disable_smart_shrinking: true }
        end
      end

      # GET /reviews/1
      # GET /reviews/1.json
      def show
        authorize @review
      end

      # GET /reviews/1/edit
      def edit
        authorize @review
        @reviewer = @review.reviewer
        build_criteria_reviews
      end

      # # POST /reviews
      # # POST /reviews.json
      def create
        @review = Review.new(grant_submission_submission_id: params[:submission_id],
                             reviewer_id: params[:reviewer_id],
                             assigner: current_user)
        authorize @review
        respond_to do |format|
          if @review.save
            ReviewerMailer.assignment(review: @review).deliver_now
            flash[:success] = "Submission assigned for review. Notification email was sent to #{helpers.full_name(@review.reviewer)}."
            format.json   { head :ok }
          else
            flash[:alert] = @review.errors.full_messages
            format.json   { head :unprocessable_entity }
          end
        end
      end

      # PATCH/PUT /reviews/1
      # PATCH/PUT /reviews/1.json
      def update
        authorize @review
        respond_to do |format|
          if @review.update(review_params)
            set_redirect_path
            format.html { redirect_to @redirect_path,
                          notice: 'Review was successfully updated.' }
            format.json { render :show, status: :ok, location: @review }
          else
            flash.now[:alert] = @review.errors.full_messages
            build_criteria_reviews
            format.html { render :edit }
            format.json { render json: @review.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /reviews/1
      # DELETE /reviews/1.json
      def destroy
        authorize @review
        @review.destroy
        ReviewerMailer.unassignment(review: @review).deliver_now
        respond_to do |format|
          flash[:success] = 'Review was successfully unassigned.'
          format.json { head :no_content }
        end
      end

      private

      def build_criteria_reviews
        @review.grant.criteria.each do |criterion|
          unless @review.criteria_reviews.detect{ |cr| cr.criterion_id == criterion.id }.present?
            @review.criteria_reviews.build(criterion: criterion)
          end
        end
      end

      def set_review_grant_and_submission
        @grant      = Grant.kept.with_criteria.friendly.find(params[:grant_id])
        @submission = @grant.submissions.kept.find(params[:submission_id])
        @review     = @submission.reviews.kept.includes(:criteria, submission: :applicant).find(params[:id])
      end

      def set_redirect_path
        @redirect_path  = if current_user.get_role_by_grant(grant: @grant)
                            grant_reviews_path(@grant)
                          else
                            profile_reviews_path
                          end
      end

      def review_params
        params.require(:review).permit(:overall_impact_score,
                                       :overall_impact_comment,
                                       criteria_reviews_attributes: [
                                        :id,
                                        :criterion_id,
                                        :score,
                                        :comment])
      end
    end
  end
end
