# frozen_string_literal: true

require 'rails_helper'

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
  it { is_expected.to respond_to(:max_reviewers_per_submission) }
  it { is_expected.to respond_to(:max_submissions_per_reviewer) }
  it { is_expected.to respond_to(:review_open_date) }
  it { is_expected.to respond_to(:review_close_date) }
  it { is_expected.to respond_to(:discarded_at) }
  it { is_expected.to respond_to(:reviewer_invitations) }
  it { is_expected.to respond_to(:contacts) }

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
        grant.slug = Faker::Alphanumeric.alpha(number: Grant::SLUG_MIN_LENGTH - 1)
        expect(grant).not_to be_valid
        expect(grant.errors).to include :slug
        grant.slug = Faker::Alphanumeric.alpha(number: Grant::SLUG_MIN_LENGTH)
        expect(grant).to be_valid
      end

      it "requires a slug to be at no more than #{Grant::SLUG_MAX_LENGTH} characters long" do
        grant.slug = Faker::Alphanumeric.alpha(number: Grant::SLUG_MAX_LENGTH + 1)
        expect(grant).not_to be_valid
        expect(grant.errors).to include :slug
        grant.slug = Faker::Alphanumeric.alpha(number: Grant::SLUG_MAX_LENGTH)
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

  describe 'Discard' do
    it 'cannot be destroyed' do
      expect{grant.destroy}.to raise_error(SoftDeleteException, 'Grants must be discarded.')
    end

    context 'published open grant' do
      let(:published_open_grant) { create(:published_open_grant) }

      it 'is not discardable' do
        expect(published_open_grant.is_discardable?).to be false
        expect(published_open_grant.errors.messages[:base]).to include 'Published grant may not be deleted.'
      end

      it 'is_open?' do
        expect(published_open_grant.is_open?).to be true
      end

      it 'is accepting_submissions?' do
        expect(published_open_grant.accepting_submissions?).to be true
      end
    end

    context 'published closed grant' do
      let(:published_closed_grant) { create(:published_closed_grant) }

      it 'is not discardable' do
        expect(published_closed_grant.is_discardable?).to be false
        expect(published_closed_grant.errors.messages[:base]).to include 'Published grant may not be deleted.'
      end

      it 'not is_open?' do
        expect(published_closed_grant.is_open?).to be false
      end

      it 'is not accepting_submissions?' do
        expect(published_closed_grant.accepting_submissions?).to be false
      end
    end

    context 'published not yet open' do
      let(:published_not_yet_open) { create(:published_not_yet_open_grant) }

      it 'is not discardable' do
        expect(published_not_yet_open.is_discardable?).to be false
        expect(published_not_yet_open.errors.messages[:base]).to include 'Published grant may not be deleted.'
      end

      it 'not is_open?' do
        expect(published_not_yet_open.is_open?).to be false
      end

      it 'is not accepting_submissions?' do
        expect(published_not_yet_open.accepting_submissions?).to be false
      end

      context 'discard' do
        it 'is not valid to be discarded' do
          expect(published_not_yet_open.reload.valid?(:discard)).to be false
          expect(published_not_yet_open.errors.messages[:base]).to include 'Published grant may not be deleted.'
        end
      end
    end

    context 'draft grant' do
      let(:draft_grant) { create(:draft_open_grant_with_users_and_form_and_submission_and_reviewer) }
      let(:submission)  { review.submission }
      let(:review)      { create(:review, submission: draft_grant.submissions.first,
                                          assigner:   draft_grant.admins.first,
                                          reviewer:   draft_grant.reviewers.first) }
      let(:panel)       { draft_grant.panel }

      context 'discarding' do
        it 'is discardable' do
          expect(draft_grant.is_discardable?).to be true
          expect(draft_grant.errors.messages[:base]).to be_empty
        end

        it 'is not accepting_submissions?' do
          expect(draft_grant.accepting_submissions?).to be false
        end

        it 'discards associated submission' do
          expect do
            draft_grant.discard
          end.to change{ submission.reload.discarded_at }
        end

        it 'discards associated review' do
          expect do
            draft_grant.discard
          end.to change{ review.reload.discarded_at }
        end

        it 'discards associated panel' do
          expect do
            draft_grant.discard
          end.to change{ panel.reload.discarded_at }
        end
      end

      context '#validations' do
        context ':discard' do
          it 'is valid to be discarded' do
            expect(draft_grant.reload.valid?(:discard)).to be true
            expect(draft_grant.errors).to be_empty
          end
        end
      end

      context 'undiscarding' do
        before(:each) do
          draft_grant.discard
        end

        it 'undiscards submissions' do
          expect do
            draft_grant.undiscard
          end.to change{submission.reload.discarded_at}.to(nil)
             .and change{ GrantSubmission::Submission.kept.count }.by 1
        end

        it 'undiscards reviews' do
          expect do
            draft_grant.undiscard
          end.to change{review.reload.discarded_at}.to(nil)
             .and change{ Review.kept.count }.by 1
        end

        it 'undiscards panel' do
          expect do
            draft_grant.undiscard
          end.to change{panel.reload.discarded_at}.to(nil)
             .and change{ Panel.kept.count }.by 1
        end
      end
    end

    context 'completed grant' do
      let (:completed_grant) { create(:grant, :completed) }

      it 'is not discardable' do
        expect(completed_grant.is_discardable?).to be false
        expect(completed_grant.errors.messages[:base]).to include 'Completed grant may not be deleted.'
      end

      it 'not is_open?' do
        expect(completed_grant.is_open?).to be false
      end

      it 'is not accepting_submissions?' do
        expect(completed_grant.accepting_submissions?).to be false
      end

      context '#validations' do
        context ':discard' do
          it 'is not valid to be discarded' do
            expect(completed_grant.reload.valid?(:discard)).to be false
            expect(completed_grant.errors.messages[:base]).to include 'Completed grant may not be deleted.'
          end
        end
      end
    end

  end

  describe '#methods' do
    let(:grant)     { create(:published_open_grant_with_users, :with_reviewer) }
    let(:new_user)  { create(:user) }

    context 'roles' do
      context '#admins' do
        it 'returns admins' do
          expect(grant.admins.count).to eql 1
          grant.grant_permissions.create(grant: grant, user: new_user, role: 'admin')
          expect(grant.admins.count).to eql 2
          expect(grant.admins.last.id).to eql new_user.id
        end
      end

      context '#editors' do
        it 'returns editors' do
          expect(grant.editors.count).to eql 1
          grant.grant_permissions.create(grant: grant, user: new_user, role: 'editor')
          expect(grant.editors.count).to eql 2
          expect(grant.editors.last.id).to eql new_user.id
        end
      end

      context '#viewers' do
        it 'returns viewers' do
          expect(grant.viewers.count).to eql 1
          grant.grant_permissions.create(grant: grant, user: new_user, role: 'viewer')
          expect(grant.viewers.count).to eql 2
          expect(grant.viewers.last.id).to eql new_user.id
        end
      end
    end
  end

  describe '#scopes' do
    let(:grant_with_unrequired_criterion) { create(:grant, :with_unrequired_commentable_criterion) }
  
    context 'criteria' do
      it 'returns correct number of required_criteria' do
        expect(grant_with_unrequired_criterion.criteria.count).to be 4
        expect(grant_with_unrequired_criterion.required_criteria.count).to be 3
      end
    end
  end

end
