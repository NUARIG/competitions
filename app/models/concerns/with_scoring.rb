module WithScoring
  extend ActiveSupport::Concern

  MINIMUM_ALLOWED_SCORE = 1
  MAXIMUM_ALLOWED_SCORE = 9

  def calculate_average_score(scores)
    scores = scores.compact
    return 0 if scores.empty?
    (scores.sum.to_f / scores.size).round(2)
  end
end
