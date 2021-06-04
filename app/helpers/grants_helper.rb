# frozen_string_literal: true

module GrantsHelper
  def grant_can_be_deleted?(grant)
    grant.submissions.none? && grant.state.in?(Grant::SOFT_DELETABLE_STATES)
  end

  def populate_grant_tabs(grant_permission_role:, grant:)
    case grant_permission_role
    when 'editor', 'admin'
      { (grant.published? ? 'View' : 'Preview') => grant_path(grant),
        'Overview'            => edit_grant_path(grant),
        'Submission Form' => edit_grant_form_path(grant, grant.form),
        'Review Form'     => criteria_grant_path(grant),
        'Submissions'     => grant_submissions_path(grant),
        'Reviewers'       => grant_reviewers_path(grant),
        'Reviews'         => grant_reviews_path(grant),
        'Panel'           => edit_grant_panel_path(grant),
        'Permissions'     => grant_grant_permissions_path(grant) }
    when 'viewer'
      { 'View'            => grant_path(grant),
        'Overview'        => edit_grant_path(grant),
        'Submission Form' => edit_grant_form_path(grant, grant.form),
        'Review Form'     => criteria_grant_path(grant),
        'Submissions'     => grant_submissions_path(grant),
        'Reviews'         => grant_reviews_path(grant),
        'Permissions'     => grant_grant_permissions_path(grant) }
    else
      { 'View'        => grant_path(grant),
        'Apply'       => grant_apply_path(grant, grant.form) }
    end
  end
end
