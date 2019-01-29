require 'rails_helper'

RSpec.describe Grant, type: :model do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:short_name) }
  it { is_expected.to respond_to(:state) }
  it { is_expected.to respond_to(:initiation_date) }
  it { is_expected.to respond_to(:submission_open_date) }
  it { is_expected.to respond_to(:submission_close_date) }
  it { is_expected.to respond_to(:rfa) }
  it { is_expected.to respond_to(:min_budget) }
  it { is_expected.to respond_to(:max_budget) }
  it { is_expected.to respond_to(:applications_per_user) }
  it { is_expected.to respond_to(:review_guidance) }
  it { is_expected.to respond_to(:max_reviewers_per_proposal) }
  it { is_expected.to respond_to(:max_proposals_per_reviewer) }
  it { is_expected.to respond_to(:panel_date) }
  it { is_expected.to respond_to(:panel_location) }

  let(:grant)   { FactoryBot.build(:grant) }

  describe '#validations' do
    it 'validates a valid grant' do
      expect(grant).to be_valid
    end
  #   it 'validates a grant without a name' do
  #     grant.name = nil
  #     expect(grant).not_to be_valid
  #     expect(grant.errors).to include :name
  #   end

  #   # it 'validates a grant without a short_name' do
  #   #   grant.short_name = nil
  #   #   expect(grant).not_to be_valid
  #   #   expect(grant.errors).to include :short_name
  #   # end

  #   it 'validates unique name and short_name' do
  #     grant.save
  #     new_grant = Grant.new(name: grant.name, short_name: grant.short_name)
  #     expect(new_grant).not_to be_valid
  #     expect(new_grant.errors).to include :name
  #     expect(new_grant.errors).to include :short_name
  end
end
