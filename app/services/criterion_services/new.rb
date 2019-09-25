# frozen_string_literal: true

module CriterionServices
  module New
    def self.call(grant:)
      ActiveRecord::Base.transaction(requires_new: true) do
        Criterion::DEFAULT_CRITERIA.each do |criterion|
          Criterion.create(grant: grant,
                           name: criterion,
                           description: '',
                           is_mandatory: true,
                           show_comment_field: true)
        end
      end
    end
  end
end
