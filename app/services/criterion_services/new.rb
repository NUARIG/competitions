# frozen_string_literal: true

module CriterionServices
  module New
    def self.call(grant:)
      ActiveRecord::Base.transaction(requires_new: true) do
        Criterion::DEFAULT_CRITERIA.each do |criterion|
          Criterion.create!(grant: grant,
                           name: criterion,
                           description: '',
                           is_mandatory: true,
                           show_comment_field: true)
        rescue ActiveRecord::RecordInvalid => invalid
          raise ServiceError::InputInvalid.new(error: invalid)
        end
      end
    end
  end
end
