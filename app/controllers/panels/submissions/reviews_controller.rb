module Panels
  module Submissions
    class ReviewsController < ApplicationController
      before_action :set_grant
      before_action :set_panel
      before_action :authorize_panel

      before_action :set_submission
      skip_after_action :verify_policy_scoped, only: :index

      def index
        @q              = Review.kept.completed.with_criteria_reviews.with_reviewer.by_submission(@submission).ransack(params[:q])
        @q.sorts        = 'overall_impact_score asc' if @q.sorts.empty?
        @pagy, @reviews = pagy(@q.result, i18n_key: 'activerecord.models.review')
      end

      private

      def set_grant
        @grant = Grant.kept.friendly.with_criteria.find(params[:grant_id])
      end

      def set_panel
        @panel = @grant.panel
      end

      def authorize_panel
        authorize @panel, :show?
      end

      def set_submission
        @submission = GrantSubmission::Submission.kept.with_applicant.find(params[:submission_id])
      end
    end
  end
end
