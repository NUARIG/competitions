# frozen_string_literal: true

class GrantReviewer < ApplicationRecord
  has_paper_trail versions: { class_name: 'PaperTrail::GrantReviewerVersion' },
                  meta:     { grant_id: :grant_id , reviewer_id: :reviewer_id }

  attr_accessor :reviewer_email

  belongs_to :grant
  belongs_to :reviewer, class_name: 'User',
                        foreign_key: :reviewer_id
                        
  validates_presence_of   :grant, :reviewer
  validates_uniqueness_of :reviewer, scope: :grant

  def can_be_assigned?(submission:)
    return false if submission.grant != grant || submission.applicants.includes?(reviewer)
    return false if submission.reviewers.includes?(reviewer)

    reviewer.reviews.by_grant(grant).length < grant.max_submissions_per_reviewer
  end
end
