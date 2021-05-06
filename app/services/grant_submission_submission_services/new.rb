# frozen_string_literal: true

module GrantSubmissionSubmissionServices
  module New
    def self.call(submission:, user:)
      ActiveRecord::Base.transaction(requires_new: true) do
        submission.save!
        GrantSubmission::Applicant.create!(submission: submission, user: user)
      end
      OpenStruct.new(success?: true)
    rescue ActiveRecord::RecordInvalid => invalid
      OpenStruct.new(success?: false,
                     messages: invalid.record.errors.full_messages)
    rescue ServiceError::InputInvalid => invalid
      OpenStruct.new(success?: false,
                     messages: invalid.record.errors.full_messages)
      # submission.errors.to_a
    end
  end
end
