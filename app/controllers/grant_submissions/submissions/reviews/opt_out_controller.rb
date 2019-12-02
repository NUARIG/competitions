module GrantSubmissions
  module Submissions
    module Reviews
      class OptOutController < ReviewsController
        def destroy
          authorize @review, :opt_out?
          @review.destroy
          ReviewerMailer.opt_out(review: @review).deliver_now
          respond_to do |format|
            flash[:warning] = 'You have opted out of the review. Assigner or grant administrators have been notified.'
            # TODO: redirect to my reviews path
            format.html { redirect_to root_path }
          end
        end
      end
    end
  end
end
