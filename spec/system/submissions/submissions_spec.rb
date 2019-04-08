# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Submissions', type: :system do
  describe 'New Submissions', js: true do
    before(:each) do
      @organization = create(:organization)
      @user         = create(:user, organization: @organization)
      @admin_user   = create(:user, organization: @organization)
      @grant        = create(:published_open_grant, organization: @organization)
      @grant_user   = create(:admin_grant_user, grant_id: @grant.id,
                                                           user_id: @admin_user.id)
    end

    # let(:submission) { create(:submitted_submission_with_complete_closed_grant, grant: @grant, user: @user) }

    scenario 'User can open a new submission' do
      login_as(@user)
      visit grant_path(@grant.id)

      # Grant show page
      expect(page).to have_content @grant.name
      click_link 'Apply'
      expect(page.current_path).to eq(new_grant_submission_path(@grant))

      # Submission new page
      page.fill_in 'Project Title', with: 'My Project Title'
      click_button 'Save and Submit'
      expect(page.current_path).to eq(grant_submission_path(@grant, Submission.last.id))

      submission = Submission.last
      expect(submission.grant).to eql(@grant)
      expect(submission.user).to eql(@user)
      expect(submission.project_title).to eql('My Project Title')
      expect(submission.state).to eql('submitted')
    end

    scenario 'Index displays submissions' do
      @submission = create(:submitted_submission_with_published_closed_grant, grant: @grant, user: @user)

      login_as(@admin_user)
      visit grant_submissions_path(@grant.id)
      expect(page).to have_content @submission.project_title
    end

    scenario 'User can only see their own submissions on index' do

    end

  end
end
