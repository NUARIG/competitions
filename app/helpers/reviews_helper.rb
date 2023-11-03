module ReviewsHelper
  def display_review_data(review:, user:, grant: review.grant, submission: review.submission)
    link  = review_link_based_on_state(review)

    if review.submitted?
      overall_impact_score = review.overall_impact_score
      composite_score = review.composite_score
    elsif review.reviewer == user
      # Assigned/Draft overall impact score may be nil   
      overall_impact_score = (review.overall_impact_score || '-')
      composite_score = '-'
    else 
      overall_impact_score = '-'
      composite_score = '-'
    end

    OpenStruct.new(status: review.state,
                    link: link,
                    overall_impact_score: overall_impact_score,
                    composite_score: composite_score,
                    created_date: time_tag(review.created_at, review.created_at.to_date.to_formatted_s(:default)),
                    due_date: time_tag(review.grant.review_close_date.end_of_day, review.grant.review_close_date.to_formatted_s(:default)))
  end

  def find_review_by_submission_and_reviewer(submission, reviewer)
    Review.find_by(submission: submission, reviewer: reviewer)
  end

  def no_score_abbreviation
    content_tag(:abbr, 'NS', title: 'No Score')
  end

  def display_review_state(state)
    begin
      I18n.t("activerecord.attributes.review.state.#{state}", :raise => true)
    rescue I18n::MissingTranslationData
      'Unknown'
    end 
  end

  def review_link_based_on_state(review)
    if review.submitted?
      link_to_if review.grant.published?, display_review_state(review.state), grant_submission_review_path(review.grant, review.submission, review)
    else
      link_to_if review.grant.published?, display_review_state(review.state), edit_grant_submission_review_path(review.grant, review.submission, review)
    end
  end
end
