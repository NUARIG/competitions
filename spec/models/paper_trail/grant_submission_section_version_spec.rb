require 'rails_helper'

RSpec.describe PaperTrail::GrantSubmission::SectionVersion, type: :model, versioning: true do
  before(:each) do
    @grant   = create(:grant, :with_users_and_submission_form)
    @form    = @grant.form
    @section = @form.sections.first
  end

  context 'metadata' do
    it 'tracks grant_submission_form_id' do
      expect(@section.versions.last.grant_submission_form_id).to eql @form.id
    end
  end
end
