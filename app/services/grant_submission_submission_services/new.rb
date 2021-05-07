# frozen_string_literal: true

module GrantSubmissionSubmissionServices
  module New
    def self.call(submission:, applicant:)
      ActiveRecord::Base.transaction(requires_new: true) do
        submission.save!
        GrantSubmission::SubmissionApplicant.create!(submission: submission, applicant: applicant)
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
