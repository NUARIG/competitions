module GrantSubmissions::SubmissionsHelper
  def review_data(submission)
    if submission.reviews.any?
      reviews = submission.reviews.to_a
      OpenStruct.new(completed_review_count: reviews.count{ |review| !review.overall_impact_score.nil? },
                     assigned_review_count:  reviews.count,
                     overall_impact_average: submission.average_overall_impact_score,
                     composite_score:        submission.composite_score )
    else
      OpenStruct.new(completed_review_count: '0',
                     assigned_review_count:  '0',
                     overall_impact_average: '-',
                     composite_score:        '-')
    end
  end
end
