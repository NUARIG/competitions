require 'rails_helper'

RSpec.describe 'GrantSubmission::Responses', type: :system do
  def successfully_saved_submission_message
    'Draft submission was saved. It can not be reviewed until it has been submitted.'
  end

  def successfully_submitted_submission_message
    'You successfully applied'
  end

  def successfully_updated_draft_submission_message
    'Draft submission was successfully updated and saved. It can not be reviewed until it has been submitted.'
  end

  describe 'Published Open Grant', js: true do
    let(:grant)             { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:grant_permission)  { create(:admin_grant_permission, grant: grant)}
    let(:submitter)         { create(:saml_user) }

    let(:draft_submission) { create(:draft_submission_with_responses_with_applicant, grant:      grant,
                                                                                      form:       grant.form,
                                                                                      created_id: submitter.id,
                                                                                      title:      Faker::Lorem.sentence,
                                                                                      state:      'draft') }

    let(:multiple_choice_question)  { grant.questions.where(response_type: 'pick_one').first }
    let(:file_upload_question)      { grant.questions.where(response_type: 'file_upload').first }
    let(:short_text_question)       { grant.questions.where(response_type: 'short_text').first }
    let(:long_text_question)        { grant.questions.where(response_type: 'long_text').first }
    let(:multiple_choice_question)  { grant.questions.where(response_type: 'pick_one').first }
    let(:number_question)           { grant.questions.where(response_type: 'number').first }
    let(:file_upload_question)      { grant.questions.where(response_type: 'file_upload').first }


    describe 'as an submitter' do
      before(:each) do
        login_as(submitter, scope: :saml_user)
        grant_permission
        visit grant_apply_path(grant)
        find_field('Your Project\'s Title', with: '').set(Faker::Lorem.sentence)
      end

      context 'valid submission' do
        scenario 'accepts a pick_one response' do
          select("#{multiple_choice_question.multiple_choice_options.first.text}", from: multiple_choice_question.text)
          click_button 'Submit'
          expect(page).to have_content successfully_submitted_submission_message
        end

        scenario 'accepts a file_upload response' do
          page.fill_in('Short Text Question', with: Faker::Lorem.sentence, currently_with: '' )
          page.fill_in('Number Question', with: Faker::Number.number(digits: 10), currently_with: '' )
          page.fill_in('Long Text Question', with: Faker::Lorem.paragraph_by_chars(number: 100), currently_with: '' )
          page.attach_file(file_upload_question.text, Rails.root.join('spec', 'support', 'file_upload', 'text_file.pdf'))
          click_button 'Submit'
          expect(page).to have_content successfully_submitted_submission_message
        end
      end

      context 'invalid submission' do
        context 'single question' do
          scenario 'requires response mandatory short_text question' do
            short_text_question.update(is_mandatory: true)

            find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
            find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 100))
            click_button 'Submit'
            expect(page).not_to have_content successfully_submitted_submission_message
            expect(page).to have_content "Response to '#{short_text_question.text}' is required."
          end

          scenario 'requires response mandatory long_text question' do
            long_text_question.update(is_mandatory: true)

            find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
            find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
            click_button 'Submit'
            expect(page).not_to have_content successfully_submitted_submission_message
            expect(page).to have_content "Response to '#{long_text_question.text}' is required."
          end

          scenario 'requires response mandatory pick_one question' do
            multiple_choice_question.update(is_mandatory: true)

            find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
            find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
            find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 100))
            click_button 'Submit'
            expect(page).not_to have_content successfully_submitted_submission_message
            expect(page).to have_content "A selection for '#{multiple_choice_question.text}' is required."
          end

          context 'number' do
            scenario 'requires response mandatory number question' do
              number_question.update(is_mandatory: true)
              find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
              find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 100))
              click_button 'Submit'
              expect(page).not_to have_content successfully_submitted_submission_message
              expect(page).to have_content "Response to '#{number_question.text}' is required."
            end

            context 'must not be text' do
              before(:each) do
                find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
                find_field(number_question.text, with: '').set('Ten')
                find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 100))
              end

              scenario 'when submitted' do

                click_button 'Submit'
                expect(page).not_to have_content successfully_submitted_submission_message
                expect(page).to have_content "Response to '#{number_question.text}' must be a number."
              end

              scenario 'when saved as draft' do
                click_button 'Save as Draft'
                expect(page).not_to have_content successfully_submitted_submission_message
                expect(page).to have_content "Response to '#{number_question.text}' must be a number."
              end
            end

            context 'must not contain text' do
              before(:each) do
                find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
                find_field(number_question.text, with: '').set('123.00aaa')
                find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
              end

              scenario 'when submitted' do
                click_button 'Submit'
                expect(page).not_to have_content successfully_submitted_submission_message
                expect(page).to have_content "Response to '#{number_question.text}' must be a number."
              end

              scenario 'when saved as draft' do
                click_button 'Save as Draft'
                expect(page).not_to have_content successfully_submitted_submission_message
                expect(page).to have_content "Response to '#{number_question.text}' must be a number."
              end
            end
          end

          context 'file_upload' do
            scenario 'requires a file_upload response' do
              file_upload_question.update(is_mandatory: true)
              find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
              find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
              find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 100))

              click_button 'Submit'
              expect(page).not_to have_content successfully_submitted_submission_message
            end
          end

          context 'combined questions' do
            context 'file_upload' do
              context 'with another invalid response' do
                before(:each) do
                  find_field('Number Question', with:'').set('Number')
                  page.attach_file(file_upload_question.text, Rails.root.join('spec', 'support', 'file_upload', 'text_file.pdf'))
                  click_button 'Submit'
                end

                scenario 'do not receive success message on field with wrong type of response' do
                  expect(page).not_to have_content successfully_submitted_submission_message
                  expect(page).to have_link 'text_file.pdf'
                end
              end
            end
          end
        end
      end

      context 'states' do
        context 'saving as draft' do
          scenario 'saves when no answer for required short text' do
            find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
            find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 100))
            click_button 'Save as Draft'
            expect(page).to have_content successfully_saved_submission_message
            expect(page).to have_content GrantSubmission::Submission.last.title
            expect(page).to have_content 'Edit'
          end
        end

        context 'submitting' do
          before(:each) do
            short_text_question.update(is_mandatory: true)
          end

          scenario 'throws error when no answer for required short text' do
            find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
            find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
            click_button 'Submit'

            expect(page).to have_content 'Please review the following error'
            expect(page).to have_content "Response to 'Short Text Question' is required."
            expect(page).to have_content 'Your responses have highlighted errors.'
          end

          scenario 'accepts submission with answer for required short text' do
            find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
            find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
            find_field('Short Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 200))
            click_button 'Submit'

            expect(page).to have_content successfully_submitted_submission_message
            expect(page).to have_current_path profile_submissions_path
            expect(page).to have_content GrantSubmission::Submission.last.title
            expect(page).not_to have_content 'Edit'
          end
        end

        context 'updating' do
          before(:each) do
            short_text_question.update(is_mandatory: true)
            visit(edit_grant_submission_path(grant, draft_submission))
          end

          context 'draft' do
            scenario 'saves short text response is required' do
              find_field('Number Question').set(Faker::Number.number(digits: 10))
              find_field('Long Text Question').set(Faker::Lorem.paragraph_by_chars(number: 100))
              click_button 'Save as Draft'

              expect(page).to have_content successfully_updated_draft_submission_message
              expect(page).to have_current_path profile_submissions_path
              expect(page).to have_content GrantSubmission::Submission.last.title
              expect(page).to have_content 'Edit'
            end
          end

          context 'submit' do
            scenario 'throws error when no answer for required short text' do
              find_field('Short Text Question').set('')
              click_button 'Submit'
              expect(page).to have_content 'Please review the following error'
              expect(page).to have_content 'Your responses have highlighted errors.'
            end
          end
        end
      end
    end
  end
end
