require 'rails_helper'
include UsersHelper

RSpec.describe ReviewerMailer, type: :mailer do
  context 'assignment' do
    let(:grant)    { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:review)   { create(:incomplete_review, assigner: grant.editors.first,
                                                reviewer: grant.reviewers.first,
                                                submission: grant.submissions.first) }
    let(:reviewer) { review.reviewer }
    let(:mailer)   { described_class.assignment(review: review) }

    it 'uses the reviewer\'s email address' do
      expect(mailer.to).to eql [reviewer.email]
    end

    it 'addresses the reviewer by their full name' do
      expect(mailer.body.encoded).to include "Dear #{reviewer.first_name} #{CGI.escapeHTML(reviewer.last_name)}"
    end

    it 'includes a link to the submission page' do
      expect(mailer.body.encoded).to have_link review.submission.title, href: grant_submission_url(grant, review.submission)
    end

    it 'includes a link to the grant page' do
      expect(mailer.body.encoded).to have_link grant.name, href: grant_url(grant)
    end
  end

  context 'unassignment' do
    let(:grant)    { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:review)   { create(:incomplete_review, assigner: grant.editors.first,
                                                reviewer: grant.reviewers.first,
                                                submission: grant.submissions.first) }
    let(:reviewer) { review.reviewer }
    let(:mailer)   { described_class.unassignment(review: review) }

    it 'uses the reviewer\'s email address' do
      expect(mailer.to).to eql [reviewer.email]
    end

    it 'addresses the reviewer by their full name' do
      expect(mailer.body.encoded).to include "Dear #{reviewer.first_name} #{reviewer.last_name}"
    end

    it 'includes a link to the grants page' do
      expect(mailer.body.encoded).to have_link grant.name, href: grant_url(grant)
    end
  end

  context 'opt_out' do
    let(:grant)    { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:review)   { create(:incomplete_review, assigner: grant.editors.second,
                                                reviewer: grant.reviewers.first,
                                                submission: grant.submissions.first) }
    let(:reviewer) { review.reviewer }

    it 'uses the assigner\'s email address' do
      @mailer = described_class.opt_out(review: review)
      expect(@mailer.to).to eql [review.assigner.email]
    end

    it 'uses the only grant administrator\'s when the assigner has no grant permission' do
      GrantPermission.find_by(user_id: review.assigner.id).destroy
      @grant_admin = User.find_by(id: grant.grant_permissions.where(role: 'admin').pluck(:user_id))

      @mailer = described_class.opt_out(review: review)
      expect(@mailer.to).to eql [@grant_admin.email]
    end

    it 'uses all grant administrators emails when the assigner has no grant permission' do
      GrantPermission.find_by(user_id: review.assigner.id).destroy
      GrantPermission.where(grant_id: grant.id).update_all(role: 'admin')

      @grant_admin = User.find_by(id: grant.grant_permissions.where(role: 'admin').pluck(:user_id))
      @mailer = described_class.opt_out(review: review)
      expect(@mailer.to).to eql grant.editors.pluck(:email)
    end

    it 'includes the reviewer name in the body' do
      @mailer = described_class.opt_out(review: review)
      expect(@mailer.body.encoded).to include "#{reviewer.first_name} #{CGI.escapeHTML(reviewer.last_name)}"
    end

    it 'includes a link to the grant in the body' do
      @mailer = described_class.opt_out(review: review)
      expect(@mailer.body.encoded).to have_link grant.name, href: grant_url(grant)
    end

    it 'includes a link to the grant reviewer page in the body' do
      @mailer = described_class.opt_out(review: review)
      expect(@mailer.body.encoded).to have_link href: grant_reviewers_url(grant)
    end
  end
end
