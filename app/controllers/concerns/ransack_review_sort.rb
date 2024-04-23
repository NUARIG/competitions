module RansackReviewSort
  extend ActiveSupport::Concern

  # Explicitly favors submitted reviews when sorting on overall_impact_score 
  def set_ransack_submission_reviews_sort_query_results(submission)
    overall_impact_sort_query_order = overall_impact_score_sort

    if overall_impact_sort_query_order.present?
      @q        = Review.includes(:grant, :reviewer, :criteria_reviews, submission: [:applicants, :submitter]).by_submission(submission).order(state: :desc).order(overall_impact_score: overall_impact_sort_query_order).ransack()
      @q.sorts  = ['state desc', params[:q]['s']]
    else
      @q        = Review.includes(:grant, :reviewer, :criteria_reviews, submission: [:applicants, :submitter]).by_submission(submission).ransack(params[:q])
      @q.sorts  = ['reviewer_last_name asc', 'overall_impact_score desc'] if @q.sorts.empty?
    end
  end

  def set_ransack_grant_reviews_sort_query_results(grant)
    overall_impact_sort_query_order = overall_impact_score_sort

    if overall_impact_sort_query_order.present?
      @q        = Review.includes(:grant, :reviewer, :criteria_reviews, submission: [:applicants, :submitter]).by_grant(grant).order(state: :desc).order(overall_impact_score: overall_impact_score_sort).ransack()
      @q.sorts  = ['state desc', params[:q]['s']]
    else
      @q        = Review.includes(:grant, :reviewer, :criteria_reviews, submission: [:applicants, :submitter]).by_grant(grant).ransack(params[:q])
      @q.sorts  = ['reviewer_last_name asc', 'overall_impact_score desc'] if @q.sorts.empty?
    end
  end

  def overall_impact_score_sort
    sort_query = params.dig(:q, :s)
    overall_impact_score_sort_order = sort_query.split(' ').last.to_sym if sort_query&.include?('overall_impact_score')
  end
end
