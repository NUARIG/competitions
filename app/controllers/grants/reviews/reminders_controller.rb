module Grants
  module Reviews
    class RemindersController < ReviewsController
      skip_after_action :verify_policy_scoped, only: :index

      def index
        @grant = Grant.kept.friendly.find(params[:grant_id])
        authorize @grant, :grant_editor_access?

        @incomplete_reviews_by_reviewer = @grant.reviews.with_reviewer.incomplete.group_by(&:reviewer)

        if @incomplete_reviews_by_reviewer.any?
          send_reminder_emails
          flash[:notice] = 'Reviewers with incomplete and draft reviews have been sent an email reminder.'
        else
          flash[:warning] = 'There are no reviewers with incomplete or draft reviews.'
        end
        redirect_to grant_reviews_path(@grant)
      end

      private

      def send_reminder_emails
        @incomplete_reviews_by_reviewer.each do |reviewer, incomplete_reviews|
          ReminderMailer.grant_reviews_reminder(grant: @grant, reviewer: reviewer, incomplete_reviews: incomplete_reviews).deliver_now

          incomplete_reviews.each do |review|
            review.update_column(:reminded_at, Time.now)
          end
        end
      end
    end
  end
end
