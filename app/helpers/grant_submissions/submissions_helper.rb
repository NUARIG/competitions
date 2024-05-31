module GrantSubmissions::SubmissionsHelper
  def review_data(submission)
    if submission.reviews.any?
      reviews = submission.reviews
      OpenStruct.new(completed_review_count: reviews.submitted.length,
                     assigned_review_count: reviews.length,
                     overall_impact_average: submission.average_overall_impact_score,
                     composite_score: submission.composite_score)
    else
      OpenStruct.new(completed_review_count: '0',
                     assigned_review_count: '0',
                     overall_impact_average: '-',
                     composite_score: '-')
    end
  end

  def applicant_label(applicants)
    "#{'Applicant'.pluralize(applicants.length)}:"
  end

  def display_assign_review_content(grant:, submission:, user_grant_role:)
    return if user_grant_role == 'viewer' || !submission.available_for_review_assignment?

    if submission.submitted?
      display_assign_reviews_link(grant: grant,
                                  submission: submission)
    else
      display_may_not_be_reviewed_span
    end
  end

  def display_may_not_be_reviewed_span
    content_tag(:span, '-', class: 'not-allowed', title: 'Draft submissions may not be assigned for review')
  end

  def display_assign_reviews_link(grant:, submission:)
    link_to('Assign', new_grant_submission_assign_review_path(grant, submission),
            data: { turbo_frame: :modal }).html_safe
  end

  def truncated_submission_select_options(submissions:)
    submissions&.collect { |s| [truncated_submission_text(submission: s), s.id] }
  end

  def truncated_submission_text(submission:)
    truncate("#{full_name(submission.submitter)} - #{submission.title}", length: 80)
  end
end
