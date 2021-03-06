# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantServices do
  describe 'DuplicateDependencies' do
    before(:each) do
      @original_grant = create(:grant_with_users)
      @new_grant      = create(:grant,  duplicate: true,
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

      it 'duplicates grant_permissions for valid new grant' do
        new_grant_permission_count = @original_grant.grant_permissions.count

        expect do
          GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
        end.to (change{GrantPermission.count}.by (new_grant_permission_count))
      end

      it 'duplicates criteria for valid new grant' do
        new_criteria_count = @original_grant.criteria.count

        expect do
          GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
        end.to (change{Criterion.count}.by (new_criteria_count))
      end

      it 'duplicates grant_submission_form for valid new grant' do
        expect do
          GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
        end.to (change{GrantSubmission::Form.count}.by (1))
      end

      context 'panels' do
        it 'duplicates panel for valid new grant' do
          expect do
            GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
          end.to (change{Panel.count}.by (1))
        end

        it 'clears dates from duplicated panel' do
          GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
          expect(Panel.last.start_datetime).to be nil
          expect(Panel.last.end_datetime).to be nil
        end
      end
    end

    context 'invalid grant' do
      it 'does not duplicate grant_permissions' do
        result =  GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @invalid_grant)
        expect(result.success?).to eql(false)
        expect(@invalid_grant.grant_permissions.count).to eql(0)
      end

      it 'does not duplicate criteria' do
        result =  GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @invalid_grant)
        expect(result.success?).to eql(false)
        expect(@invalid_grant.criteria.count).to eql(0)
      end
    end
  end
end
