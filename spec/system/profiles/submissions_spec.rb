require 'rails_helper'
include UsersHelper

RSpec.describe 'Profile Submissions', type: :system, js: true do
  let(:grant)            { create(:open_grant_with_users_and_form_and_submission_and_reviewer, name: "First #{Faker::Lorem.sentence(word_count: 3)}") }
  let(:grant2)           { create(:open_grant_with_users_and_form_and_submission_and_reviewer, name: "Second #{Faker::Lorem.sentence(word_count: 3)}") }
  let(:submission)       { grant.submissions.first }
  let(:draft_submission) { create(:draft_submission_with_responses, grant: grant2,
                                                                    form: grant2.form,
                                                                    applicant: applicant) }
  let(:applicant)        { submission.applicant }
  let(:user)             { create(:saml_user) }

  context 'header text' do
    context 'applicant' do
      scenario 'displays MySubmissions link in the header' do
        login_user(applicant)

        visit root_path
        expect(page).to have_link('MySubmissions', href: profile_submissions_path)
      end
    end

    context 'user with no submissions' do
      scenario 'does not display MySubmissions link in the header' do
        login_user(user)

        visit root_path
        expect(page).not_to have_link('MySubmissions', href: profile_submissions_path)
      end
    end
  end

  context '#index' do
    before(:each) do
      [submission, draft_submission]
      login_user(applicant)
      visit profile_submissions_path
    end

    scenario 'it does not include links to the user\'s submitted submissions' do
      expect(page).to have_text submission.title
      expect(page).not_to have_link('Edit', href: edit_grant_submission_path(grant, submission))
    end

    scenario 'it includes edit links to the user\'s draft submissions' do
      expect(page).to have_text draft_submission.title
      expect(page).to have_link('Edit', href: edit_grant_submission_path(grant2, draft_submission))
    end

    scenario 'it can be filtered on grant name' do
      find_field('Search Grant or Project', with: '').set('First')
      click_button 'Search'

      expect(page).to have_text(submission.title)
      expect(page).to have_link(grant.name, href: grant_path(grant))
      expect(page).not_to have_text(grant2.name)
      expect(page).not_to have_text(draft_submission.title)
    end

    scenario 'it does not include submissions from discarded grant' do
      expect(page).to have_text(grant.name)
      expect(page).to have_text(submission.title)

      grant.discard
      visit profile_submissions_path

      expect(page).not_to have_text(grant.name)
      expect(page).not_to have_text(submission.title)
    end
  end
end
