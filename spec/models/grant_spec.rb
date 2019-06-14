# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples/soft_deletable'

RSpec.describe Grant, type: :model do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:slug) }
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

    context 'name' do
      it 'requires a name' do
        grant.name = nil
        expect(grant).not_to be_valid
        expect(grant.errors).to include :name
      end

      it 'requires unique name' do
        grant.save
        new_grant = Grant.new(name: grant.name)
        expect(new_grant).not_to be_valid
        expect(new_grant.errors.messages[:name]).to eq ['has already been taken']
      end
    end

    context 'slug' do
      it 'requires a slug' do
        grant.slug = nil
        expect(grant).not_to be_valid
        expect(grant.errors).to include :slug
      end

      it 'requires unique slug' do
        grant.save
        new_grant = Grant.new(name: "New #{grant.name}", slug: grant.slug)
        expect(new_grant).not_to be_valid
        expect(new_grant.errors.messages[:slug]).to eq ['has already been taken']
      end

      it "requires a slug to be at least #{Grant::SLUG_MIN_LENGTH} characters long" do
        grant.slug = Faker::Alphanumeric.alpha(Grant::SLUG_MIN_LENGTH - 1)
        expect(grant).not_to be_valid
        expect(grant.errors).to include :slug
        grant.slug = Faker::Alphanumeric.alpha(Grant::SLUG_MIN_LENGTH)
        expect(grant).to be_valid
      end

      it "requires a slug to be at no more than #{Grant::SLUG_MAX_LENGTH} characters long" do
        grant.slug = Faker::Alphanumeric.alpha(Grant::SLUG_MAX_LENGTH + 1)
        expect(grant).not_to be_valid
        expect(grant.errors).to include :slug
        grant.slug = Faker::Alphanumeric.alpha(Grant::SLUG_MAX_LENGTH)
        expect(grant).to be_valid
      end

      it 'requires case-sensitive slug' do
        grant.save
        new_grant = Grant.new(name: "New #{grant.name}", slug: grant.slug.capitalize)
        expect(new_grant).not_to be_valid
        expect(new_grant.errors.messages[:slug]).to eq ['has already been taken']
      end

      it 'trims slug of whitespace before validation' do
        grant.slug = "  new-slug  "
        expect(grant).to be_valid
        grant.save
        expect(grant.slug).to eql 'new-slug'
      end

      it 'disallows spaces in slug' do
        grant.slug = "new grant"
        expect(grant).not_to be_valid
        expect(grant.errors).to include :slug
      end

      it 'disallows non-alphanumeric slugs' do
        grant.slug = "new&grant"
        expect(grant).not_to be_valid
        expect(grant.errors).to include :slug
      end

      it 'disallows numeric slugs' do
        grant.slug = "123456"
        expect(grant).not_to be_valid
        expect(grant.errors).to include :slug
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
  end

  context 'published open grant' do
    let(:published_open_grant) { create(:published_open_grant) }

    it 'cannot soft deleted' do
      expect(published_open_grant.deleted?).to be false
      expect{published_open_grant.is_soft_deletable?}.to raise_error(SoftDeleteException, 'Published grant may not be deleted')
      expect{published_open_grant.soft_delete!}.to raise_error('Published grant may not be deleted')
      expect(published_open_grant.deleted?).to be false
    end

    it 'is accepting_submissions?' do
      expect(published_open_grant.accepting_submissions?).to be true
    end
  end

  context 'published closed grant' do
    let(:published_closed_grant) { create(:published_closed_grant) }

    it 'cannot soft deleted' do
      expect(published_closed_grant.deleted?).to be false
      expect{published_closed_grant.is_soft_deletable?}.to raise_error(SoftDeleteException, 'Published grant may not be deleted')
      expect{published_closed_grant.soft_delete!}.to raise_error('Published grant may not be deleted')
      expect(published_closed_grant.deleted?).to be false
    end

    it 'is accepting_submissions?' do
      expect(published_closed_grant.accepting_submissions?).to be false
    end
  end

  context 'published not yet  open' do
    let(:published_not_yet_open) { create(:published_not_yet_open_grant) }

    it 'cannot soft deleted' do
      expect(published_not_yet_open.deleted?).to be false
      expect{published_not_yet_open.is_soft_deletable?}.to raise_error(SoftDeleteException, 'Published grant may not be deleted')
      expect{published_not_yet_open.soft_delete!}.to raise_error('Published grant may not be deleted')
      expect(published_not_yet_open.deleted?).to be false
    end

    it 'is accepting_submissions?' do
      expect(published_not_yet_open.accepting_submissions?).to be false
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

    it 'is not accepting_submissions?' do
      expect(draft_grant.accepting_submissions?).to be false
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

    it 'is not accepting_submissions?' do
      expect(completed_grant.accepting_submissions?).to be false
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

    it 'is not accepting_submissions?' do
      expect(demo_grant.accepting_submissions?).to be false
    end
  end
end

