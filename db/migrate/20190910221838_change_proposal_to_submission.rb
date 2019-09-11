class ChangeProposalToSubmission < ActiveRecord::Migration[5.2]
  def up
    rename_column :grants, :max_reviewers_per_proposal, :max_reviewers_per_submission
    rename_column :grants, :max_proposals_per_reviewer, :max_submissions_per_reviewer
  end

  def down
    rename_column :grants, :max_reviewers_per_submission, :max_reviewers_per_proposal
    rename_column :grants, :max_submissions_per_reviewer, :max_proposals_per_reviewer
  end
end
