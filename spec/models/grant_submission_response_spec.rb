require 'rails_helper'

RSpec.describe GrantSubmission::Response, type: :model do
  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:question) }
  it { is_expected.to respond_to(:multiple_choice_option) }
  it { is_expected.to respond_to(:document) }
  it { is_expected.to respond_to(:text_val) }
  it { is_expected.to respond_to(:decimal_val) }
  it { is_expected.to respond_to(:datetime_val) }
  it { is_expected.to respond_to(:boolean_val) }

  describe '#validations' do
    let(:grant)       { create(:published_open_grant_with_users)}
    let(:other_grant) { create(:published_open_grant_with_users)}
    let(:submission)  { create(:grant_submission_submission, grant: grant, form: grant.form)}
    let(:response)    { create(:string_val_response, submission: submission,
                                                     question: grant.form.questions.where(response_type: 'short_text').first)}

    it 'validates response to a question from the grant' do
      expect(response).to be_valid
    end

    it 'invalidates response to a question from another grant' do
      response.update_attribute(:grant_submission_question_id, other_grant.form.questions.where(response_type: 'short_text').first.id)
      expect(response).not_to be_valid
      expect(response.errors).to include(:grant_submission_question_id)
    end
  end
end
