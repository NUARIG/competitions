# frozen_string_literal: true

# Creates a starter Form, Section, and Question for a new Grant
module GrantSubmissionFormServices
  module New
    def self.call(grant:, user:)
      begin
        # TODO: is requires_new needed?
        ActiveRecord::Base.transaction(requires_new: true) do
          # Create a form
          new_form = GrantSubmission::Form.create(grant: grant,
                                                  submission_instructions: '',
                                                  created_id: user.id,
                                                  updated_id: user.id)

          # Create a 'Basic Attributes' section
          form_section = new_form.sections.create(title: 'Basic Attributes',
                                                  display_order: 1)

          # Create an 'Abstract' long_text question
          form_section.questions.create(text: 'Abstract',
                                        display_order: 1,
                                        is_mandatory: true,
                                        response_type: 'long_text')

          # Create an 'Application Document' file_upload question
          form_section.questions.create(text: 'Application Document',
                                        display_order: 2,
                                        is_mandatory: true,
                                        response_type: 'file_upload')
        end
      rescue ActiveRecord::Invalid => invalid
        raise ServiceError(err: invalid)
      end
    end
  end
end
