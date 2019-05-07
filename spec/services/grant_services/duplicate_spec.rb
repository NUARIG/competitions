# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantServices do
  describe 'DuplicateDependencies' do
    before(:each) do
      @original_grant = create(:grant, :with_users)
      @new_grant      = create(:grant, duplicate: true,
                                             name: 'New Name',
                                             slug: 'NewShort')
      @invalid_grant  = build(:grant, name: '')
    end

    context 'valid grant' do
      it 'returns :success? true on successful duplication' do
        result = GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
        expect(result.success?).to eql(true)
      end

      it 'returns :success? false on successful duplication' do
        result = GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @invalid_grant)
        expect(result.success?).to eql(false)
      end

      it 'duplicates grant_users for valid new grant' do
        new_grant_user_count = @original_grant.grant_users.count

        expect do
          GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
        end.to (change{GrantUser.count}.by (new_grant_user_count))
      end
    end

    context 'invalid grant' do
      it 'does not duplicate grant_users' do
        result =  GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @invalid_grant)
        expect(result.success?).to eql(false)
        expect(@invalid_grant.grant_users.count).to eql(0)
      end
    end
  end
end
