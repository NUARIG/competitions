class RecalculateSubmissionScores < ActiveRecord::Migration[5.2]
  def change
    # See: AddAverageScoreColumnsToGrantSubmissionSubmissions
    #      fix improperly updated score columns
    GrantSubmission::Submission.all.each do |submission|
      submission.set_average_overall_impact_score
      submission.set_composite_score
    end
  end
end
