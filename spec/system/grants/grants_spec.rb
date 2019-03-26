# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Grants', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      @organization = FactoryBot.create(:organization)
      @user         = FactoryBot.create(:user, organization: @organization)
      @grant        = FactoryBot.create(:grant, organization: @organization)
      @grant_user   = FactoryBot.create(:admin_grant_user, grant_id: @grant.id,
                                                           user_id: @user.id)

      login_as(@user)
      visit edit_grant_path(@grant.id)
    end

    scenario 'date fields edited with datepicker are properly formatted' do
      tomorrow = (Date.current + 1.day).to_s

      expect(page).to have_field('grant_publish_date', with: @grant.publish_date)
      page.execute_script("$('#grant_publish_date').fdatepicker('setDate',new Date('#{tomorrow}'))")
      click_button 'Save and Complete'

      expect(@grant.reload.publish_date.to_s).to eql(tomorrow)
    end

    scenario 'versioning tracks whodunnit', versioning: true do
      expect(PaperTrail).to be_enabled
      fill_in 'grant_name', with: 'New_Name'
      click_button 'Save and Complete'

      expect(page).to have_content 'Grant was successfully updated.'
      expect(@grant.versions.last.whodunnit).to eql(@user.id)
    end
  end

  describe 'New', js: true do
    before(:each) do
      #TODO: Streamline DefaultSet factory creation to include Questions and ConstraintQuestions
      @default_set  = FactoryBot.create(:default_set)
      @contsraint_question1 = FactoryBot.create(:string_minimum_number_of_characters_constraint_question)
      @contsraint_question2 = FactoryBot.create(:string_maximum_number_of_characters_constraint_question, question: @contsraint_question1.question)
      @default_set.questions << @contsraint_question1.question
      @grant        = FactoryBot.build(:grant, default_set: @default_set.id)
      @user         = FactoryBot.create(:user, organization: @grant.organization,
                                               organization_role: 'admin')
      login_as(@user)

      visit new_grant_path
      select(@default_set.name, from: 'grant[default_set]')

      page.fill_in 'Name', with: @grant.name
      page.fill_in 'Short Name', with: @grant.short_name
      # TODO: Figure out rspec / trix
      # page.find('grant_rfa').click.set(@grant.grant_rfa)
      # page.find('review_guidance').click.set(@grant.review_guidance)
      page.fill_in 'Publish Date', with: @grant.publish_date
      page.fill_in 'Open Date', with: @grant.submission_open_date
      page.fill_in 'Close Date', with: @grant.submission_close_date
      page.fill_in 'Maximum Reviewers / Proposal', with: @grant.max_reviewers_per_proposal
      page.fill_in 'Maximum Proposals / Reviewer', with: @grant.max_proposals_per_reviewer
      page.fill_in 'Review Open Date', with: @grant.review_open_date
      page.fill_in 'Review Close Date', with: @grant.review_close_date
      page.fill_in 'Panel Location', with: @grant.panel_location
    end

    scenario 'valid form submission creates constraints and permissions' do
      click_button 'Save as Draft'

      grant = Grant.last
      expect(grant.name).to eql(@grant.name)
      expect(page.current_path).to eq(grant_questions_path(grant))
      expect(grant.state).to eql('draft')
      expect(page).to have_content 'Grant saved'
      expect(page).to have_content @default_set.questions.first.text
      click_link('Permissions', href: grant_grant_users_path(grant).to_s)
      expect(page).to have_content @user.name
      expect(grant.users.count).to eql 1
      expect(@user.grant_users.where(grant: grant).first.grant_role).to eql 'admin'
    end

    scenario 'invalid form submission does not create constraints and permissions' do
      grant_user_count          = GrantUser.all.count
      question_count            = Question.all.count
      constraint_question_count = ConstraintQuestion.all.count

      page.fill_in 'Close Date', with: (@grant.submission_open_date - 1.day)
      click_button 'Save as Draft'
      expect(page).to have_content 'Submission close date must be after the opening date for submissions.'
      expect(GrantUser.all.count).to eql(grant_user_count)
      expect(Question.all.count).to eql(question_count)
      expect(ConstraintQuestion.all.count).to eql(constraint_question_count)
    end
  end
end
