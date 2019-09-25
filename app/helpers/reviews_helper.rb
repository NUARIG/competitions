module ReviewsHelper
  def find_review_by_submission_and_reviewer(submission, reviewer)
    Review.find_by(submission: submission, reviewer: reviewer)
  end
end
