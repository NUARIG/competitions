require 'rails_helper'
include ActionDispatch::TestProcess::FixtureFile

RSpec.describe GrantSubmission::Response, type: :model do
  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:question) }
  it { is_expected.to respond_to(:multiple_choice_option) }
  it { is_expected.to respond_to(:document) }
  it { is_expected.to respond_to(:text_val) }
  it { is_expected.to respond_to(:decimal_val) }
  it { is_expected.to respond_to(:datetime_val) }
  it { is_expected.to respond_to(:boolean_val) }
  it { is_expected.to respond_to(:document) }

  describe '#validations' do
    let(:grant)       { create(:published_open_grant_with_users)}
    let(:other_grant) { create(:published_open_grant_with_users)}
    let(:submission)  { create(:grant_submission_submission, grant: grant, form: grant.form)}

    context 'string_val' do
      let(:response)    { create(:string_val_response, submission: submission,
                                                       question:   grant.form.questions.where(response_type: 'short_text').first)}

      context '#validations' do
        it 'validates response to a question from the grant' do
          expect(response).to be_valid
        end

        it 'validates if response is to a question from another grant' do
          response.update_attribute(:grant_submission_question_id, other_grant.form.questions.where(response_type: 'short_text').first.id)
          expect(response).not_to be_valid
          expect(response.errors).to include(:grant_submission_question_id)
        end

        it 'validates length' do
          response.update_attribute(:string_val, Faker::Lorem.characters(number: 256))
          expect(response).not_to be_valid
          expect(response.errors).to include(:string_val)
        end

        it 'validates if attachment' do
          response.document.attach(io: File.open(Rails.root.join('spec', 'support', 'file_upload', 'text_file.pdf')), filename: 'text_file.pdf')
          expect(response).not_to be_valid
          expect(response.errors).to include(:document)
        end
      end
    end

    context 'file_upload' do
      let(:grant)                { create(:open_grant_with_users_and_form_and_submission_and_reviewer)}
      let(:file_upload_question) { create(:file_upload_question, section: grant.form.sections.first,
                                                                 display_order: grant.form.questions.pluck(:display_order).max + 1) }

      context 'valid file type upload' do
        let(:response) { build(:valid_file_upload_response, submission: grant.submissions.first,
                                                             question: file_upload_question) }

        it 'validates response with a attached file' do
          expect(response.document.attached?).to be true
          expect(response).to be_valid
        end

        it 'requires a files size below 15MB' do
          expect(response).to be_valid
          allow(response.document).to receive_message_chain(:filename, :extension_with_delimiter).and_return('.pdf')
          allow(response.document).to receive_message_chain(:blob, :byte_size).and_return(16.megabytes)
          expect(response).not_to be_valid
        end
      end

      context 'invalid file type upload' do
        let(:response) { build(:invalid_file_upload_response, submission: grant.submissions.first,
                                                               question: file_upload_question) }

        it 'validates response an invalid attached file' do
          expect(response).not_to be_valid
        end
      end
    end
  end
end
