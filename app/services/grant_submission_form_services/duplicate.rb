module GrantSubmissionFormServices
  module Duplicate
    def self.call(original_grant:, new_grant:)
      begin
        # TODO: is requires_new needed?
        ActiveRecord::Base.transaction(requires_new: true) do
          # copy the original form to new form
          original_form = original_grant.form
          new_form      = original_form.dup
          new_form.update_attributes!(grant_id: new_grant.id)
          # loop through the sections
          original_form.sections.each do |original_section|
            new_section = original_section.dup
            # assign section to new_form
            new_section.update_attributes!(grant_submission_form_id: new_form.id)
            # loop through the questions
            original_section.questions.each do |question|
              new_question = question.dup
              new_question.grant_submission_section_id = new_section.id
              # loop through the multiple_choice_options
              if new_question.response_type == 'pick_one'
                new_question.save!(:validate => false)
                question.multiple_choice_options.each do |option|
                  new_option = option.dup
                  new_option.update_attributes!(grant_submission_question_id: new_question.id)
                end
              else
                new_question.save!
              end
            end
          rescue ActiveRecord::RecordInvalid => invalid
            raise ServiceError.new(invalid: invalid)
          end
        end
      end
    end
  end
end
