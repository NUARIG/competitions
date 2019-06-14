module GrantSubmissionFormServices
  module Duplicate
    def self.call(original_grant:, new_grant:)
      begin
        # TODO: is requires_new needed?
        ActiveRecord::Base.transaction(requires_new: true) do
          # copy the original form to new form
          original_form = original_grant.form
          new_form      = original_form.dup
          new_form.update_attributes!(grant_id: new_grant.id,
                                      title: "Grant #{original_grant.id}: #{original_form.title} Section - Duplicated")
          # loop through the sections
          original_form.sections.each do |original_section|
            new_section = original_section.dup
            # assign section to new_form
            new_section.update_attributes!(grant_submission_form_id: new_form.id)
            # loop through the questions
            original_section.questions.each do |question|
              new_question = question.dup
              new_question.update_attributes!(grant_submission_section_id: new_section.id)
            end
          end
        end
      end
    end
  end
end
