require 'rails_helper'

RSpec.describe GrantCreatorRequest, type: :model do
  it { is_expected.to respond_to (:requester) }
  it { is_expected.to respond_to (:request_comment) }
  it { is_expected.to respond_to (:reviewer) }
  it { is_expected.to respond_to (:status) }

  describe '#validations' do
    let(:request)          { build(:grant_creator_request) }

    it 'validates a valid request' do
      expect(request).to be_valid
    end

    it 'requires a request_comment' do
      request.request_comment = nil
      expect(request).not_to be_valid
      expect(request.errors).to include(:request_comment)
    end

    it 'disallows request from system_admin' do
      request.requester.update_attribute(:system_admin, true)
      expect(request).not_to be_valid
      expect(request.errors[:base]).to include I18n.t('activerecord.errors.models.grant_creator_request.attributes.base.is_system_admin')
    end

    it 'disallows request from grant_creator' do
      request.requester.update_attribute(:grant_creator, true)
      expect(request).not_to be_valid
      expect(request.errors[:base]).to include I18n.t('activerecord.errors.models.grant_creator_request.attributes.base.has_grant_creator_access')
    end

    it 'disallows request from user with an exisiting pending request' do
      request.save
      expect(FactoryBot.build(:grant_creator_request, requester: request.requester)).not_to be_valid
    end

    it 'allows request from user with an exisiting rejected request' do
      request.update_attribute(:status, 'rejected')
      request.save
      expect(FactoryBot.build(:grant_creator_request, requester: request.requester)).to be_valid
    end
  end

  describe 'status' do
    let(:request) { FactoryBot.create(:grant_creator_request) }

    it 'defaults to status: pending' do
      expect(request.status).to eql 'pending'
    end

    it 'requires status to be in STATUSES' do
      expect{ build(:grant_creator_request, status: 'not so random state')}.to raise_error(ArgumentError)
    end
  end

  describe 'reviews' do
    let(:request)          { build(:grant_creator_request) }
    let(:valid_reviewer)   { create(:system_admin_user) }
    let(:invalid_reviewer) { create(:user) }

    context 'valid reviews' do
      before(:each) do
        request.reviewer = valid_reviewer
      end

      it 'allows reviewer who is a system_admin' do
        request.reviewer_id = valid_reviewer.id
        expect(request).to be_valid
      end

      it 'sets requester grant_creator boolean to false when rejected' do
        expect(request.requester.grant_creator).to be false
        request.update_attribute(:status, 'rejected')
        expect(request.requester.grant_creator).to be false
      end

      it 'sets requester grant_creator boolean to true when approved' do
        expect(request.requester.grant_creator).to be false
        request.status = 'approved'
        request.save
        expect(request.requester.grant_creator).to be true
      end

      it 'sets requester grant_creator boolean to false when pending' do
        expect(request.requester.grant_creator).to be false
        request.update_attribute(:status, 'pending')
        expect(request.requester.grant_creator).to be false
      end
    end

    context 'invalid reviews' do
      it 'disallows reviewer who is not a system_admin' do
        request.save
        request.reviewer = invalid_reviewer
        expect(request).not_to be_valid
        expect(request.errors.messages[:base]).to include  I18n.t('activerecord.errors.models.grant_creator_request.attributes.base.reviewer_is_not_system_admin')
      end
    end
  end
end
