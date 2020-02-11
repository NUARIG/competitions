require 'rails_helper'

RSpec.describe GrantReviewer, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:reviewer) }

  describe '#validations' do
    let(:grant_reviewer) { FactoryBot.build(:grant_reviewer) }

    it 'validates a valid grant' do
      expect(grant_reviewer).to be_valid
    end

    it 'validates presence of grant' do
      grant_reviewer.grant = nil
      expect(grant_reviewer).not_to be_valid
      expect(grant_reviewer.errors).to include(:grant)
    end

    it 'requires a valid grant_id' do
      grant_reviewer.grant_id = Grant.last.id + 1
      expect(grant_reviewer).not_to be_valid
      expect(grant_reviewer.errors).to include(:grant)
    end

    it 'validates presence of reviewer' do
      grant_reviewer.reviewer = nil
      expect(grant_reviewer).not_to be_valid
      expect(grant_reviewer.errors).to include(:reviewer)
    end

    it 'requires a valid reviewer_id' do
      grant_reviewer.reviewer_id = User.last.id + 1
      expect(grant_reviewer).not_to be_valid
      expect(grant_reviewer.errors).to include(:reviewer)
    end
  end

  describe '#scoped validations' do
    before(:each) do
      @gr  = FactoryBot.create(:grant_reviewer)
      @gr2 = FactoryBot.build(:grant_reviewer, grant: @gr.grant, reviewer: @gr.reviewer)
    end

    it 'validates grant and reviewer scope' do
      expect(@gr2).not_to be_valid
      expect(@gr2.errors).to include(:reviewer)
    end
  end
end
