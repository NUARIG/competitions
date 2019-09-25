require 'rails_helper'

RSpec.describe 'GrantReviewers', type: :system do
  describe '#index', js: true do
    before(:each) do
      @grant        = create(:open_grant_with_users_and_form_and_submission_and_reviewer,
                             max_submissions_per_reviewer: Faker::Number.between(1, 10),
                             max_reviewers_per_submission: Faker::Number.between(1, 10))
      @grant_admin  = @grant.editors.first
      @reviewer     = @grant.reviewers.first
      @user         = create(:user)
      @unknown_user = build(:user)

      login_as(@grant_admin)
      visit grant_reviewers_path(@grant)
    end

    scenario 'max_reviewers_per_submission is displayed' do
      expect(page).to have_content("Each reviewer may assess up to #{@grant.max_submissions_per_reviewer} #{'submission'.pluralize(@grant.max_submissions_per_reviewer)}.")
    end

    scenario 'displays reviewer name and number of available reviews' do
      expect(page).to have_content("#{@reviewer.first_name} #{@reviewer.last_name} ( #{@grant.max_submissions_per_reviewer} )")
    end
  end

  describe '#create', js: true do
    before(:each) do
      @grant        = create(:open_grant_with_users_and_form_and_submission_and_reviewer,
                             max_submissions_per_reviewer: Faker::Number.between(1, 10),
                             max_reviewers_per_submission: Faker::Number.between(1, 10))
      @grant_admin  = @grant.editors.first
      @reviewer     = @grant.reviewers.first
      @user         = create(:user)
      @unknown_user = build(:user)

      login_as(@grant_admin)
      visit grant_reviewers_path(@grant)
    end

    scenario 'existing users may be added as reviewers' do
      expect(page).not_to have_content("#{@user.first_name} #{@user.last_name}")
      page.fill_in 'Email', with: @user.email
      click_button 'Look Up'
      expect(page).to have_content("#{@user.first_name} #{@user.last_name}")
    end

    scenario 'unknown users may not be added as reviewers' do
      page.fill_in 'Email', with: @unknown_user.email
      click_button 'Look Up'
      expect(page).to have_content("Could not find user with email: #{@unknown_user.email}")
      expect(page).not_to have_content("#{@unknown_user.first_name} #{@unknown_user.last_name}")
    end
  end

  describe '#destroy', js: true do
    before(:each) do
      @grant        = create(:open_grant_with_users_and_form_and_submission_and_reviewer,
                             max_submissions_per_reviewer: Faker::Number.between(1, 10),
                             max_reviewers_per_submission: Faker::Number.between(1, 10))
      @grant_admin  = @grant.editors.first
      @reviewer     = @grant.reviewers.first
      @review       = create(:review, assigner: @grant_admin,
                                      reviewer: @reviewer,
                                      submission: @grant.submissions.first)
      @user         = create(:user)
      @unknown_user = build(:user)

      login_as(@grant_admin)
      visit grant_reviewers_path(@grant)
    end

    scenario 'reviewer can be deleted' do
      click_link('Remove', href: grant_reviewer_path(@grant, @grant.grant_reviewers.first))
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content "Reviewer and their reviews have been deleted for this grant."
    end

    scenario 'reviewer and reveiwer submissions can be deleted' do
      reviewer = @grant.grant_reviewers.first.reviewer
      expect(reviewer.reviews.by_grant(Grant.last).count).to eq(1)
      click_link('Remove', href: grant_reviewer_path(@grant, @grant.grant_reviewers.first))
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content 'Reviewer and their reviews have been deleted for this grant.'
      expect(reviewer.reviews.by_grant(Grant.last).count).to eq(0)
    end

    scenario 'displays error when reviewer is not found' do
      allow_any_instance_of(GrantReviewer).to receive(:nil?).and_return(true)
      click_link('Remove', href: grant_reviewer_path(@grant, @grant.grant_reviewers.first))
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content('Reviewer could not be found.')
    end
  end
end
