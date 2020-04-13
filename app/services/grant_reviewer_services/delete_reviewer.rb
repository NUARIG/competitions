module GrantReviewerServices
  module DeleteReviewer
    def self.call(grant_reviewer:)
      ActiveRecord::Base.transaction do
        grant_reviewer.destroy!

        Review.by_reviewer(grant_reviewer.reviewer)
              .by_grant(grant_reviewer.grant)
              .destroy_all
      end
      OpenStruct.new(success?: true,
                     messages: 'Reviewer and their reviews have been deleted for this grant.')
    end
  end
end
