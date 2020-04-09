# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CriterionServices::New do
  before(:each) do
    @grant = create(:grant_with_users)
  end

  it 'creates the correct number of criteria' do
    expect do
      CriterionServices::New.call(grant: @grant)
    end.to (change{@grant.criteria.count}.by (Criterion::DEFAULT_CRITERIA.count))
  end

  it 'throws ServiceError on failure' do
    expect{ CriterionServices::New.call(grant: nil) }.to raise_error(ServiceError)
  end
end
