# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantPermissionServices::Duplicate do
  before(:each) do
    @grant     = create(:grant_with_users)
    @new_grant = create(:grant)
  end

  it 'creates the correct number of criteria' do
    expect do
      GrantPermissionServices::Duplicate.call(original_grant_permission: @grant.grant_permissions.first, new_grant: @new_grant)
    end.to change{GrantPermission.count}.by (1)
    expect(@new_grant.grant_permissions.count).to eql 1
  end

  it 'throws ServiceError on failure' do
    expect{ GrantPermissionServices::Duplicate.call(original_grant_permission: @grant.grant_permissions.first, new_grant: nil) }.to raise_error(ServiceError)
  end
end
