module GrantSubmissions
  module SubmissionsHelper
    def review_data(submission)
      if submission.reviews.any?
        reviews = submission.reviews
        OpenStruct.new(completed_review_count: reviews.submitted.length,
                       assigned_review_count:  reviews.length,
                       overall_impact_average: submission.average_overall_impact_score,
                       composite_score:        submission.composite_score )
      else
        OpenStruct.new(completed_review_count: '0',
                       assigned_review_count:  '0',
                       overall_impact_average: '-',
                       composite_score:        '-')
      end
    end

    def applicant_label(applicants)
      'Applicant'.pluralize(applicants.length) + ':'
    end
  end
end
