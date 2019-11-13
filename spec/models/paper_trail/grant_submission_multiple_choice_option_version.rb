require 'rails_helper'

RSpec.describe PaperTrail::GrantSubmission::MultipleChoiceOptionVersion, type: :model, versioning: true do
  before(:each) do
    @grant    = create(:grant, :with_users_and_submission_form)
    @question = @grant.questions.find_by(response_type: 'pick_one')
    @option   = @question.multiple_choice_options.first
  end

  context 'metadata' do
    it 'tracks grant_submission_question_id' do
      expect(@option.versions.last.grant_submission_question_id).to eql @question.id
    end
  end
end
