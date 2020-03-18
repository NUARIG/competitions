require 'active_support/concern'

module WithSubmissionState
  extend ActiveSupport::Concern

  included do
    validate :cannot_update_submitted_submission, on: :update,
                                                  if: :submitted?


    def submitted?
      raise NotImplementedError, "#{self.class} does not have: "
    end

    private

    def cannot_update_submitted_submission
      errors.add(:base, 'The Submission has been submitted and cannot be changed.')
    end
  end
end
