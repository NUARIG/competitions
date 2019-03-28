# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantServices do
  describe 'DuplicateDependencies' do
    before(:each) do
      @original_grant = FactoryBot.create(:grant, :with_questions, :with_users)
      @new_grant      = FactoryBot.create(:grant, duplicate: true,
                                             name: 'New Name',
                                             short_name: 'NewShort')
      @invalid_grant  = FactoryBot.build(:grant, name: '')
    end

    it 'returns :success? true on successful duplication' do
      result = GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
      expect(result.success?).to eql(true)
    end

    it 'returns :success? false on successful duplication' do
      result = GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @invalid_grant)
      expect(result.success?).to eql(false)
    end

    it 'duplicates grant_users and questions for valid new grant' do
      new_question_count   = @original_grant.questions.count
      new_grant_user_count = @original_grant.grant_users.count
      new_constraint_count = ConstraintQuestion.where(question_id: @original_grant.questions.ids).count

      expect do
        GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @new_grant)
      end.to change{Question.count}.by(new_question_count).and (change{GrantUser.count}.by (new_grant_user_count)).and (change{ConstraintQuestion.count}.by (new_constraint_count))
    end

    it 'does not duplicate grant_users and questions' do
      result =  GrantServices::DuplicateDependencies.call(original_grant: @original_grant, new_grant: @invalid_grant)
      expect(result.success?).to eql(false)
      expect(@invalid_grant.questions.count).to eql(0)
      expect(@invalid_grant.grant_users.count).to eql(0)
    end
  end
end
