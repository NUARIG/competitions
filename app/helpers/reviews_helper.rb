module ReviewsHelper
  def find_review_by_submission_and_reviewer(submission, reviewer)
    Review.find_by(submission: submission, reviewer: reviewer)
  end

  def no_score_abbreviation
    content_tag(:abbr, 'NS', title: 'No Score')
  end
end
