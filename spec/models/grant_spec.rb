# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples/soft_deletable'

RSpec.describe Grant, type: :model do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:short_name) }
  it { is_expected.to respond_to(:state) }
  it { is_expected.to respond_to(:publish_date) }
  it { is_expected.to respond_to(:submission_open_date) }
  it { is_expected.to respond_to(:submission_close_date) }
  it { is_expected.to respond_to(:rfa) }
  it { is_expected.to respond_to(:applications_per_user) }
  it { is_expected.to respond_to(:review_guidance) }
  it { is_expected.to respond_to(:max_reviewers_per_proposal) }
  it { is_expected.to respond_to(:max_proposals_per_reviewer) }
  it { is_expected.to respond_to(:review_open_date) }
  it { is_expected.to respond_to(:review_close_date) }
  it { is_expected.to respond_to(:panel_date) }
  it { is_expected.to respond_to(:panel_location) }
  it { is_expected.to respond_to(:deleted_at) }

  let(:grant) { build(:grant) }

  describe '#validations' do
    it 'validates a valid grant' do
      expect(grant).to be_valid
    end

    context 'default set' do
      it 'requires a valid default_set' do
        grant.default_set = DefaultSet.last.id + 1
        expect(grant).not_to be_valid
        expect(grant.errors.messages[:base]).to eq ['Please choose a default question set']
      end

      it 'does not require a default_set on update' do
        grant.save
        grant.default_set = nil
        expect(grant).to be_valid
      end
    end

    context 'name and short_name' do
      it 'requires a name' do
        grant.name = nil
        expect(grant).not_to be_valid
        expect(grant.errors).to include :name
      end

      it 'requires a short_name if name is > 10 characters' do
        grant.name = 'Not Too Short'
        grant.short_name = ''
        expect(grant).not_to be_valid
        expect(grant.errors).to include :short_name
      end

      it 'does not require a short_name if name is < 10 characters' do
        grant.name = 'Too Short'
        grant.short_name = ''
        expect(grant).to be_valid
      end

      it 'requires unique name and short_name' do
        grant.save
        new_grant = Grant.new(name: grant.name, short_name: grant.short_name)
        expect(new_grant).not_to be_valid
        expect(new_grant.errors.messages[:name]).to eq ['has already been taken']
        expect(new_grant.errors.messages[:short_name]).to eq ['has already been taken']
      end
    end

    context 'dates' do
      it 'requires current or future publish_date' do
        grant.publish_date = Date.yesterday
        expect(grant).not_to be_valid
        expect(grant.errors).to include :publish_date
      end

      it 'requires submission_open_date to be on or after publish_date' do
        grant.submission_open_date = 2.days.ago
        expect(grant).not_to be_valid
        expect(grant.errors).to include :submission_open_date
      end

      it 'requires submission_close_date to be after submission_open_date' do
        grant.submission_open_date = 10.days.from_now
        grant.submission_close_date = 9.days.from_now
        expect(grant).not_to be_valid
        expect(grant.errors).to include :submission_close_date
      end

      it 'requires review_open_date to be after submission_open_date' do
        grant.review_open_date = 28.days.from_now
        grant.submission_open_date = 29.days.from_now
        expect(grant).not_to be_valid
        expect(grant.errors).to include :review_open_date
      end

      it 'requires review_close_date to be after review_open_date' do
        grant.review_open_date = 30.days.from_now
        grant.review_close_date = 29.days.from_now
        expect(grant).not_to be_valid
        expect(grant.errors).to include :review_close_date
      end
    end
  end

  describe 'SoftDeletable' do
    it 'cannot be destroyed' do
      expect{grant.destroy}.to raise_error(SoftDeleteException, 'Grants must be soft deleted.')
    end

    context 'associations' do
      pending 'associations are correctly handled' do
        fail '#TODO: determine whether any associations should also be soft_deleted'
      end
    end

    context 'published grant' do
      it 'cannot soft deleted' do
        expect(grant.deleted?).to be false
        expect{grant.is_soft_deletable?}.to raise_error(SoftDeleteException, 'Published grant may not be deleted')
        expect{grant.soft_delete!}.to raise_error('Published grant may not be deleted')
        expect(grant.deleted?).to be false
      end

      pending 'published grant with submissions cannot be deleted' do
        fail '#TODO: grant.submissions.count.zero?'
      end
    end

    context 'demo grant' do
      let (:demo_grant) { create(:grant, :demo) }

      it 'can be soft deleted' do
        expect(demo_grant.deleted?).to be false
        expect{demo_grant.is_soft_deletable?}.not_to raise_error
        expect{demo_grant.soft_delete!}.not_to raise_error
        expect(demo_grant.deleted?).to be true
      end
    end

    context 'draft grant' do
      let (:draft_grant) { create(:grant, :draft) }

      it 'can be soft deleted' do
        expect(draft_grant.deleted?).to be false
        expect{draft_grant.is_soft_deletable?}.not_to raise_error
        expect{draft_grant.soft_delete!}.not_to raise_error
        expect(draft_grant.deleted?).to be true
      end
    end

    context 'completed grant' do
      let (:completed_grant) { create(:grant, :completed) }

      it 'cannot be soft deleted' do
        expect(completed_grant.deleted?).to be false
        expect{completed_grant.is_soft_deletable?}.to raise_error(SoftDeleteException, 'Completed grant may not be deleted')
        expect{completed_grant.soft_delete!}.to raise_error('Completed grant may not be deleted')
        expect(completed_grant.deleted?).to be false
      end
    end
  end
end

