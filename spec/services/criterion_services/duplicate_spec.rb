# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CriterionServices::Duplicate do
  before(:each) do
    @criterion = create(:criterion)
    @new_grant = build(:new_grant)
  end

  context 'success' do
    it 'adds a criterion' do
      expect do
        CriterionServices::Duplicate.call(original_criterion: @criterion, new_grant: @new_grant)
      end.to (change{Criterion.count}.by 1)
    end

    it 'creates a criterion for the new grant with the same name' do
      CriterionServices::Duplicate.call(original_criterion: @criterion, new_grant: @new_grant)
      expect(@new_grant.criteria.last.name).to eql(@criterion.name)
    end
  end
end
