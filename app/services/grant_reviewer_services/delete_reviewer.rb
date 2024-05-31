module GrantReviewerServices
  module DeleteReviewer
    def self.call(grant_reviewer:)
      return failed_result unless grant_reviewer.present?

      ActiveRecord::Base.transaction do
        grant_reviewer.destroy!
        destroy_reviewer_reviews(grant_reviewer)
      rescue ActiveRecord::StatementInvalid
        return failed_result
      end
      OpenStruct.new(success?: true,
                     messages: 'Reviewer and their reviews have been deleted for this grant.')
    end

    def self.destroy_reviewer_reviews(grant_reviewer)
      Review.by_reviewer(grant_reviewer.reviewer)
            .by_grant(grant_reviewer.grant)
            .destroy_all
    end

    def self.failed_result
      OpenStruct.new(success?: false,
                     messages: 'Reviewer could not be found or deleted.')
    end
  end
end
