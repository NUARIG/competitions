# frozen_string_literal: true

# Creates a starter Form, Section, and Question for a new Grant
module GrantSubmissionFormServices
  module New
    def self.call(grant:, user:)
      # Create a form, give it a title
      new_form = GrantSubmission::Form.create(title: "#{grant.name} Submission Form",
                                              description: 'Should we use this as an intro or instruction section?',
                                              created_id: user.id,
                                              updated_id: user.id)

      # TODO: what to do with grant_forms table
      grant_form   = GrantForm.create(grant_id: grant.id,
                                      grant_submission_form_id: new_form.id,
                                      display_order: 1)
      # Create a 'Basic Attributes' section
      form_section = new_form.sections.create(title: 'Basic Attrributes',
                                              display_order: 1)

      # Create an 'Abstract' question
      form_section.questions.create(text: 'Abstract',
                                    display_order: 1,
                                    is_mandatory: true,
                                    response_type: 'long_text')
    end
  end
end
