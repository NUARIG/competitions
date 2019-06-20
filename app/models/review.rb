class Review < ApplicationRecord
  include WithScoring

  belongs_to :reviewer,       class_name: 'User',
                              foreign_key: 'created_id'
  belongs_to :submission,     class_name: 'GrantSubmission::Submission',
                              foreign_key: 'grant_submission_submission_id',
                              counter_cache: true,
                              inverse_of: :reviews
  has_many :criteria_reviews
  has_many :criteria,         through: :criteria_reviews

  # calculating averages on the fly will be easier.
  # consider whether averages should be cached.

  validates_numericality_of :overall_impact_score, only_integer: true,
                                                   greater_than_or_equal_to: MINIMUM_ALLOWED_SCORE,
                                                   less_than_or_equal_to: MAXIMUM_ALLOWED_SCORE

end


