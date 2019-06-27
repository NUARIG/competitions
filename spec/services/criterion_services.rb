# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CriterionServices do
  describe 'New' do
    before(:each) do
      @grant = create(:grant_with_users)
    end

    it 'creates the correct number of criteria' do
      expect do
        CriterionServices::New.call(grant: @grant)
      end.to (change{@grant.criteria.count}.by (Criterion::DEFAULT_CRITERIA.count))
    end
  end
end
