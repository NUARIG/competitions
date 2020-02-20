require 'rails_helper'

RSpec.describe 'GrantSubmission::Responses', type: :system do
  def successful_application_message
    'You successfully applied'
  end

  describe 'Published Open Grant', js: true do
    before(:each) do
      @grant     = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @applicant = create(:user)

      login_as(@applicant)
      visit grant_apply_path(@grant)
      find_field('Your Project\'s Title', with: '').set(Faker::Lorem.sentence)
    end

    context 'valid submission' do
      scenario 'accepts a pick_one response' do
        multiple_choice_question = @grant.questions.where(response_type: 'pick_one').first
        first_option_text        = multiple_choice_question.multiple_choice_options.first.text

        select("#{first_option_text}", from: multiple_choice_question.text)
        click_button 'Submit'
        expect(page).to have_content successful_application_message
      end

      scenario 'accepts a file_upload response' do
        file_upload_question = @grant.questions.where(response_type: 'file_upload').first
        find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
        find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
        find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
        page.attach_file(file_upload_question.text, Rails.root.join('spec', 'support', 'file_upload', 'text_file.pdf'))
        click_button 'Submit'
        expect(page).to have_content successful_application_message
      end
    end

    context 'invalid submission' do
      let(:file_upload_question) {@grant.questions.find_by(response_type: 'file_upload')}

      context 'single question' do
        scenario 'requires response mandatory short_text question' do
          short_text_question = @grant.questions.where(response_type: 'short_text').first
          short_text_question.update_attribute(:is_mandatory, true)

          find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
          find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
          click_button 'Submit'
          expect(page).not_to have_content successful_application_message
          expect(page).to have_content "Response to '#{short_text_question.text}' is required."
        end

        scenario 'requires response mandatory long_text question' do
          long_text_question = @grant.questions.where(response_type: 'long_text').first
          long_text_question.update_attribute(:is_mandatory, true)

          find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
          find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
          click_button 'Submit'
          expect(page).not_to have_content successful_application_message
          expect(page).to have_content "Response to '#{long_text_question.text}' is required."
        end

        scenario 'requires response mandatory pick_one question' do
          multiple_choice_question = @grant.questions.where(response_type: 'pick_one').first
          multiple_choice_question.update_attribute(:is_mandatory, true)

          find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
          find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
          find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
          click_button 'Submit'
          expect(page).not_to have_content successful_application_message
          expect(page).to have_content "A selection for '#{multiple_choice_question.text}' is required."
        end

        context 'number' do
          scenario 'requires response mandatory number question' do
            number_question = @grant.questions.where(response_type: 'number').first
            number_question.update_attribute(:is_mandatory, true)

            find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
            find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
            click_button 'Submit'
            expect(page).not_to have_content successful_application_message
            expect(page).to have_content "Response to '#{number_question.text}' is required."
          end

          scenario 'number question requires a number response' do
            number_question = @grant.questions.where(response_type: 'number').first

            find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
            find_field(number_question.text, with: '').set('Ten')
            find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
            click_button 'Submit'
            expect(page).not_to have_content successful_application_message
            expect(page).to have_content "Response to '#{number_question.text}' must be a number."
          end

          scenario 'number question requires a number-only response' do
            number_question = @grant.questions.where(response_type: 'number').first

            find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
            find_field(number_question.text, with: '').set('123.00aaa')
            find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
            click_button 'Submit'
            expect(page).not_to have_content successful_application_message
            expect(page).to have_content "Response to '#{number_question.text}' must be a number."
          end
        end

        scenario 'requires a file_upload response' do
          file_upload_question.update_attribute(:is_mandatory, true)
          find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
          find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
          find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))

          click_button 'Submit'
          expect(page).not_to have_content successful_application_message
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
              expect(page).not_to have_content successful_application_message
              expect(page).to have_link 'text_file.pdf'
            end

            scenario 'submits file successfully when file when validation error is corrected' do
              find_field('Number Question', with: 'Number').set(10)
              click_button 'Submit'
              expect(page).to have_content successful_application_message
              expect(GrantSubmission::Response.find_by(question: file_upload_question).document.attached?).to be true
            end
          end
        end
      end
    end









    context 'states' do
      let(:file_upload_question) {@grant.questions.find_by(response_type: 'file_upload')}

      context 'single required question' do
        context 'on create' do
          context 'saving as draft' do
            context 'requires response mandatory short_text question' do
              scenario 'no answer for required short text' do
                short_text_question = @grant.questions.where(response_type: 'short_text').first
                short_text_question.update_attribute(:is_mandatory, true)

                find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
                find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
                click_button 'Save as Draft'
                expect(page).to have_content 'You started your submission.'
                expect(page).to have_current_path profile_submissions_path
                expect(page).to have_content GrantSubmission::Submission.last.title
                expect(page).to have_content 'Edit'
              end
            end
          end

          context 'submitting' do
            context 'requires response mandatory short_text question' do
              scenario 'no answer for required short text' do
                short_text_question = @grant.questions.where(response_type: 'short_text').first
                short_text_question.update_attribute(:is_mandatory, true)

                find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
                find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
                click_button 'Submit'
                expect(page).to have_content 'Please review the following error'
                expect(page).to have_content 'is required'
              end

              scenario 'with answer for required short text' do
                short_text_question = @grant.questions.where(response_type: 'short_text').first
                short_text_question.update_attribute(:is_mandatory, true)

                find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
                find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
                find_field('Short Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 200))
                click_button 'Submit'
                expect(page).to have_content 'You successfully applied.'
                expect(page).to have_current_path profile_submissions_path
                expect(page).to have_content GrantSubmission::Submission.last.title
                expect(page).not_to have_content 'Edit'
              end
            end
          end
        end

        context 'on update' do
          before(:each) do
            @submission = create(:draft_submission_with_responses,
                                grant:      @grant,
                                form:       @grant.form,
                                created_id: @applicant.id,
                                title:      Faker::Lorem.sentence,
                                state:      'draft')
            short_text_question = @grant.questions.where(response_type: 'short_text').first
            short_text_question.update_attribute(:is_mandatory, true)

            short_text_response = @submission.responses.where(question: short_text_question).first
            short_text_response.update_attribute(:string_val, '')

            visit profile_submissions_path
          end

          context 'saving as draft' do
            context 'requires response mandatory short_text question' do
              scenario 'no answer for required short text' do
                click_link 'Edit'
                expect(page).to have_current_path edit_grant_submission_path(@grant, @submission)
                find_field('Number Question').set(Faker::Number.number(digits: 10))
                find_field('Long Text Question').set(Faker::Lorem.paragraph_by_chars(number: 1000))
                click_button 'Save as Draft'
                expect(page).to have_content 'Submission was successfully updated.'
                expect(page).to have_current_path profile_submissions_path
                expect(page).to have_content GrantSubmission::Submission.last.title
                expect(page).to have_content 'Edit'
              end
            end
          end

          context 'submitting' do
            context 'requires response mandatory short_text question' do
              scenario 'no answer for required short text' do
                click_link 'Edit'
                expect(page).to have_current_path edit_grant_submission_path(@grant, @submission)
                find_field('Number Question').set(Faker::Number.number(digits: 10))
                find_field('Long Text Question').set(Faker::Lorem.paragraph_by_chars(number: 1000))
                click_button 'Submit'
                expect(page).to have_content 'Please review the following error'
                expect(page).to have_content 'is invalid'
              end

              scenario 'with answer for required short text' do
                click_link 'Edit'
                expect(page).to have_current_path edit_grant_submission_path(@grant, @submission)
                find_field('Number Question').set(Faker::Number.number(digits: 10))
                find_field('Long Text Question').set(Faker::Lorem.paragraph_by_chars(number: 1000))
                find_field('Short Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 200))
                click_button 'Submit'
                expect(page).to have_content 'You successfully applied.'
                expect(page).to have_current_path profile_submissions_path
                expect(page).to have_content GrantSubmission::Submission.last.title
                expect(page).not_to have_content 'Edit'
              end
            end
          end
        end
      end
    end
  end
end
