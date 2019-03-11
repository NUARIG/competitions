# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grant, type: :model do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:short_name) }
  it { is_expected.to respond_to(:state) }
  it { is_expected.to respond_to(:initiation_date) }
  it { is_expected.to respond_to(:submission_open_date) }
  it { is_expected.to respond_to(:submission_close_date) }
  it { is_expected.to respond_to(:rfa) }
  it { is_expected.to respond_to(:min_budget) }
  it { is_expected.to respond_to(:max_budget) }
  it { is_expected.to respond_to(:applications_per_user) }
  it { is_expected.to respond_to(:review_guidance) }
  it { is_expected.to respond_to(:max_reviewers_per_proposal) }
  it { is_expected.to respond_to(:max_proposals_per_reviewer) }
  it { is_expected.to respond_to(:review_open_date) }
  it { is_expected.to respond_to(:review_close_date) }
  it { is_expected.to respond_to(:panel_date) }
  it { is_expected.to respond_to(:panel_location) }

  let(:grant) { FactoryBot.build(:grant) }

  describe '#validations' do
    it 'validates a valid grant' do
      expect(grant).to be_valid
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
      it 'requires current or future initiation_date' do
        grant.initiation_date = Date.yesterday
        expect(grant).not_to be_valid
        expect(grant.errors).to include :initiation_date
      end

      it 'requires submission_open_date to be on or after initiation_date' do
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

    context 'budgets' do
      it 'requires a positive or zero min_budget' do
        grant.min_budget = -1.00
        expect(grant).not_to be_valid
        expect(grant.errors).to include :min_budget
        grant.min_budget = 0
        expect(grant).to be_valid
      end

      it 'requires max_budget to be greater than min_budget' do
        grant.min_budget = 100
        grant.max_budget = 1
        expect(grant).not_to be_valid
        expect(grant.errors).to include :max_budget
        grant.min_budget = 0
        expect(grant).to be_valid
      end
    end

    context 'panel location' do
      it 'requires a panel location if panel_date is set' do
        grant.panel_location = nil
        expect(grant).not_to be_valid
        expect(grant.errors).to include :panel_location
        grant.panel_date = nil
        expect(grant).to be_valid
      end
    end
  end
end
