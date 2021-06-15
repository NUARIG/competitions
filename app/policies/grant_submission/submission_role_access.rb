module GrantSubmission::SubmissionRoleAccess
  def current_user_is_applicant?
    submission.applicants.include?(user)
  end

  def current_user_is_reviewer?
    submission.reviewers.include?(user)
  end
end
