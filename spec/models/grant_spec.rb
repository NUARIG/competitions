require 'rails_helper'

RSpec.describe Grant, type: :model do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:short_name) }

  let(:college) { FactoryBot.create(:organization) }
  let(:grant)   { FactoryBot.build(:grant) }

  describe '#validations' do
    it 'validates a grant without a name' do
      grant.name = nil
      expect(grant).not_to be_valid
      expect(grant.errors).to include :name
    end

    it 'validates a grant without a short_name' do
      grant.short_name = nil
      expect(grant).not_to be_valid
      expect(grant.errors).to include :short_name
    end

    it 'validates unique name and short_name' do
      grant.save
      new_grant = Grant.new(name: grant.name, short_name: grant.short_name)
      expect(new_grant).not_to be_valid
      expect(new_grant.errors).to include :name
      expect(new_grant.errors).to include :short_name
    end
  end
end
