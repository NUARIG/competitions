require 'rails_helper'

RSpec.describe PaperTrail::GrantSubmission::QuestionVersion, type: :model, versioning: true do
  before(:each) do
    @grant    = create(:grant, :with_users_and_submission_form)
    @section  = @grant.form.sections.first
    @question = @grant.questions.first
  end

  context 'metadata' do
    it 'tracks grant_submission_section_id' do
      expect(@question.versions.last.grant_submission_section_id).to eql @section.id
    end
  end
end
