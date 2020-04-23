class AddAverageScoreColumnsToGrantSubmissionSubmissions < ActiveRecord::Migration[5.2]
  def up
    add_column :grant_submission_submissions, :average_overall_impact_score, :decimal, { precision: 5, scale: 2 }
    add_column :grant_submission_submissions, :composite_score, :decimal, { precision: 5, scale: 2 }

    GrantSubmission::Submission.all.each do |submission|
      submission.update_attribute(:average_overall_impact_score, submission.set_average_overall_impact_score)
      submission.update_attribute(:composite_score, submission.set_composite_score)
    end
  end

  def down
    remove_column :grant_submission_submissions, :average_overall_impact_score
    remove_column :grant_submission_submissions, :composite_score
  end
end
