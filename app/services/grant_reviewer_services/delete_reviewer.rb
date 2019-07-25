module GrantReviewerServices
  module DeleteReviewer
    def self.call(grant_reviewer:)
      begin
        ActiveRecord::Base.transaction(requires_new: true) do
          Review.by_reviewer(grant_reviewer.reviewer)
                .by_grant(grant_reviewer.grant)
                .destroy_all

          grant_reviewer.destroy
        end

        OpenStruct.new(success?: true,
                       messages: 'Reviewer and their reviews have been deleted for this grant.')
      rescue
        OpenStruct.new(success?: false,
                       messages: 'Unable to delete this reviewer\'s reviews.' )
      end
    end
  end
end
