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

  let(:grant)       { create(:published_open_grant_with_users)}
  let(:other_grant) { create(:open_grant_with_users_and_form_and_submission_and_reviewer)}
  let(:submission)  { build(:grant_submission_submission, grant: grant, form: grant.form)}

  context 'string_val' do
    let(:string_val_response) { build(:string_val_response, submission: submission,
                                                            question:   grant.form.questions.where(response_type: 'short_text').first)}

    context '#validations' do
      it 'validates response to a question from the grant' do
        expect(string_val_response).to be_valid
      end

      it 'requires response when question is_mandatory' do
        string_val_response.question.update_attribute(:is_mandatory, true)
        string_val_response.update_attribute(:string_val, '')
        expect(string_val_response).not_to be_valid
        expect(string_val_response.errors).to include(:string_val)
      end

      it 'requires response to be to a question from its grant' do
        string_val_response.update_attribute(:grant_submission_question_id, other_grant.form.questions.where(response_type: 'short_text').first.id)
        expect(string_val_response).not_to be_valid
        expect(string_val_response.errors).to include(:grant_submission_question_id)
      end

      it 'validates length' do
        string_val_response.update_attribute(:string_val, Faker::Lorem.characters(number: 256))
        expect(string_val_response).not_to be_valid
        expect(string_val_response.errors).to include(:string_val)
      end

      it 'does not allow an attachment' do
        string_val_response.document.attach(io: File.open(Rails.root.join('spec', 'support', 'file_upload', 'text_file.pdf')), filename: 'text_file.pdf')
        expect(string_val_response).not_to be_valid
        expect(string_val_response.errors).to include(:document)
      end
    end

    context '#methods' do
      context 'response_value' do
        it 'reutrns the string_val text' do
          expect(string_val_response.response_value).to eql string_val_response.string_val
        end
      end

      context 'formatted_response_value' do
        it 'reutrns the string_val text' do
          expect(string_val_response.formatted_response_value).to eql string_val_response.string_val
        end
      end
    end
  end

  context 'text_val' do
    let(:text_val_response) { build(:text_val_response, submission: submission,
                                                         question:   grant.form.questions.where(response_type: 'long_text').first)}

    context '#validations' do
      it 'validates response to a question from the grant' do
        expect(text_val_response).to be_valid
      end

      it 'requires response when question is_mandatory' do
        text_val_response.question.update_attribute(:is_mandatory, true)
        text_val_response.update_attribute(:text_val, '')
        expect(text_val_response).not_to be_valid
        expect(text_val_response.errors).to include(:text_val)
      end

      it 'requires response to be to a question from its grant' do
        text_val_response.update_attribute(:grant_submission_question_id, other_grant.form.questions.where(response_type: 'long_text').first.id)
        expect(text_val_response).not_to be_valid
        expect(text_val_response.errors).to include(:grant_submission_question_id)
      end

      it 'does not allow an attachment' do
        text_val_response.document.attach(io: File.open(Rails.root.join('spec', 'support', 'file_upload', 'text_file.pdf')), filename: 'text_file.pdf')
        expect(text_val_response).not_to be_valid
        expect(text_val_response.errors).to include(:document)
      end
    end

    context '#methods' do
      context 'response_value' do
        it 'reutrns the text_val text' do
          expect(text_val_response.response_value).to eql text_val_response.text_val
        end
      end

      context 'formatted_response_value' do
        it 'reutrns the text_val text' do
          expect(text_val_response.formatted_response_value).to eql text_val_response.text_val
        end
      end
    end
  end

  context 'number' do
    let(:number_response) { build(:number_response, submission: submission,
                                                    question:   grant.form.questions.where(response_type: 'number').first)}

    context '#validations' do
      # String input specs in spec/system/grant_submission_response_spec.rb
      it 'validates response to a question from the grant' do
        expect(number_response).to be_valid
      end

      it 'requires response when question is_mandatory' do
        number_response.question.update_attribute(:is_mandatory, true)
        number_response.update_attribute(:decimal_val, '')
        expect(number_response).not_to be_valid
        expect(number_response.errors).to include(:decimal_val)
      end

      it 'requires response to be to a question from its grant' do
        number_response.update_attribute(:grant_submission_question_id, other_grant.form.questions.where(response_type: 'number').first.id)
        expect(number_response).not_to be_valid
        expect(number_response.errors).to include(:grant_submission_question_id)
      end

      it 'does not allow an attachment' do
        number_response.document.attach(io: File.open(Rails.root.join('spec', 'support', 'file_upload', 'text_file.pdf')), filename: 'text_file.pdf')
        expect(number_response).not_to be_valid
        expect(number_response.errors).to include(:document)
      end
    end

    context '#methods' do
      context 'response_value' do
        it 'reutrns the decimal_val text' do
          expect(number_response.response_value).to eql number_response.decimal_val
        end
      end

      context 'formatted_response_value' do
        it 'reutrns the decimal_val text' do
          expect(number_response.formatted_response_value).to eql number_response.decimal_val.to_s
        end
      end
    end
  end

  context 'multiple_choice_option' do
    let(:pick_one_question) { grant.form.questions.where(response_type: 'pick_one').first }
    let(:other_question)    { build(:pick_one_question_with_options) }
    let(:options)           { pick_one_question.multiple_choice_options }
    let(:pick_one_response) { build(:pick_one_response, submission: submission,
                                                        question:   pick_one_question,
                                                        multiple_choice_option: options.first) }

    context '#validations' do
      it 'validates response to a question from the grant' do
        expect(pick_one_response).to be_valid
      end

      it 'requires a choice if is_mandatory' do
        pick_one_question.is_mandatory = true
        pick_one_response.multiple_choice_option = nil
        expect(pick_one_response).not_to be_valid
        expect(pick_one_response.errors).to include(:grant_submission_multiple_choice_option_id)
      end

      it 'requires multiple_choice_option to be from the same question' do
        other_question.save
        pick_one_response.multiple_choice_option = other_question.multiple_choice_options.first
        expect(pick_one_response).not_to be_valid
      end
    end

    context '#methods' do
      context 'response_value' do
        it 'reutrns the multiple_choice_option text' do
          expect(pick_one_response.response_value).to eql options.first.text
        end
      end

      context 'formatted_response_value' do
        it 'returns the multiple_choice_option text' do
          expect(pick_one_response.formatted_response_value).to eql options.first.text
        end
      end
    end
  end

  context 'date_opt_time' do
    let(:date_response) { build(:date_opt_time_response, submission: submission,
                                                          question:   grant.form.questions.where(response_type: 'date_opt_time').first)}

    context '#validations' do
      it 'validates response to a question from the grant' do
        expect(date_response).to be_valid
      end

      it 'requires response when question is_mandatory' do
        date_response.question.update_attribute(:is_mandatory, true)
        date_response.update_attribute(:datetime_val, '')
        expect(date_response).not_to be_valid
        expect(date_response.errors).to include(:datetime_val_date_optional_time_magik)
      end

      pending 'requires a response to be a date' do
        fail 'See #295: review DateOptionalTime has_date_optional_time method'
      end

      it 'requires response to be to a question from its grant' do
        date_response.update_attribute(:grant_submission_question_id, other_grant.form.questions.where(response_type: 'number').first.id)
        expect(date_response).not_to be_valid
        expect(date_response.errors).to include(:grant_submission_question_id)
      end

      it 'does not allow an attachment' do
        date_response.document.attach(io: File.open(Rails.root.join('spec', 'support', 'file_upload', 'text_file.pdf')), filename: 'text_file.pdf')
        expect(date_response).not_to be_valid
        expect(date_response.errors).to include(:document)
      end
    end
  end

  context 'file_upload' do
    let(:grant)                { create(:open_grant_with_users_and_form_and_submission_and_reviewer)}
    let(:file_upload_question) { create(:file_upload_question, section: grant.form.sections.first,
                                                               display_order: grant.form.questions.pluck(:display_order).max + 1) }
    context '#validations' do
      context 'valid file type upload' do
        let(:file_upload_response) { build(:valid_file_upload_response, submission: grant.submissions.first,
                                                                        question: file_upload_question) }

        it 'validates response with a attached file' do
          expect(file_upload_response.document.attached?).to be true
          expect(file_upload_response).to be_valid
        end

        it 'requires a files size below 15MB' do
          expect(file_upload_response).to be_valid
          allow(file_upload_response.document).to receive_message_chain(:filename, :extension_with_delimiter).and_return('.pdf')
          allow(file_upload_response.document).to receive_message_chain(:blob, :byte_size).and_return(16.megabytes)
          expect(file_upload_response).not_to be_valid
        end
      end

      context 'invalid file type upload' do
        let(:file_upload_response) { build(:invalid_file_upload_response, submission: grant.submissions.first,
                                                                          question: file_upload_question) }

        it 'validates response an invalid attached file' do
          expect(file_upload_response).not_to be_valid
        end
      end
    end

    context '#methods' do
      let(:file_upload_response) { build(:valid_file_upload_response, submission: grant.submissions.first,
                                                                      question: file_upload_question) }

      it 'removes attached file when remove_document is 1' do
        file_upload_response.remove_document = 1
        file_upload_response.remove_document
        expect(file_upload_response.document.attached?).to be false
      end

      it 'does not remove attached file when remove_document is 0' do
        file_upload_response.remove_document = 0
        file_upload_response.remove_document
        expect(file_upload_response.document.attached?).to be true
      end
    end
  end
end
