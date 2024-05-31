require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantReviewers', type: :system do
  describe '#index', js: true do
    let(:grant) do
      create(:open_grant_with_users_and_form_and_submission_and_reviewer,
             max_submissions_per_reviewer: Faker::Number.between(from: 1, to: 10),
             max_reviewers_per_submission: Faker::Number.between(from: 1, to: 10))
    end
    let(:grant_admin)  { grant.administrators.first }
    let(:reviewer)     { grant.reviewers.first }
    let(:user)         { create(:saml_user) }
    let(:unknown_user) { build(:saml_user) }

    before(:each) do
      login_as(grant_admin, scope: :saml_user)
      visit grant_reviewers_path(grant)
    end

    scenario 'max_reviewers_per_submission is displayed' do
      expect(page).to have_content("Each reviewer may assess up to #{grant.max_submissions_per_reviewer} #{'submission'.pluralize(grant.max_submissions_per_reviewer)}.")
    end

    scenario 'displays reviewer name and number of available reviews' do
      within("##{dom_id(grant.grant_reviewers.first)}") do
        expect(page).to have_content(sortable_full_name(reviewer).to_s)
        expect(page).to have_content('0 / 0')
      end
    end
  end

  describe '#create', js: true do
    let(:grant) do
      create(:open_grant_with_users_and_form_and_submission_and_reviewer,
             max_submissions_per_reviewer: Faker::Number.between(from: 1, to: 10),
             max_reviewers_per_submission: Faker::Number.between(from: 1, to: 10))
    end
    let(:grant_admin)  { grant.administrators.first }
    let(:reviewer)     { grant.reviewers.first }
    let(:user)         { create(:saml_user) }
    let(:unknown_user) { build(:saml_user) }

    before(:each) do
      login_as(grant_admin, scope: :saml_user)
      visit grant_reviewers_path(grant)
    end

    scenario 'existing users may be added as reviewers' do
      expect(page).not_to have_content("#{user.first_name} #{user.last_name}")
      page.fill_in 'Email', with: user.email
      click_button 'Look Up'
      expect(page).to have_content("#{user.first_name} #{user.last_name}")
    end

    scenario 'unknown users may not be added as reviewers' do
      page.fill_in 'Email', with: unknown_user.email
      click_button 'Look Up'
      expect(page).to have_content("Could not find a user with the email: #{unknown_user.email}")
      expect(page).not_to have_content("#{unknown_user.first_name} #{unknown_user.last_name}")
    end

    scenario 'existing reviewer may not be added again' do
      page.fill_in 'Email', with: reviewer.email
      click_button 'Look Up'
      expect(page).to have_content(I18n.t('activerecord.errors.models.grant_reviewer.attributes.reviewer.taken'))
    end
  end

  describe '#destroy', js: true do
    let(:grant)        do
      create(:open_grant_with_users_and_form_and_submission_and_reviewer,
             max_submissions_per_reviewer: Faker::Number.between(from: 1, to: 10),
             max_reviewers_per_submission: Faker::Number.between(from: 1, to: 10))
    end
    let(:grant_admin)  { grant.administrators.first }
    let(:reviewer)     { grant.reviewers.first }
    let(:review)       do
      create(:review, assigner: grant_admin,
                      reviewer: reviewer,
                      submission: grant.submissions.first)
    end
    let(:user)         { create(:saml_user) }
    let(:unknown_user) { build(:saml_user) }

    before(:each) do
      review
      login_as(grant_admin, scope: :saml_user)
      visit grant_reviewers_path(grant)
    end

    context 'success' do
      before(:each) do
        dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"
      end
      scenario 'reviewer can be deleted' do
        dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"
        expect do
          within('#reviewers') do
            find(dropdown_menu_id).hover
            accept_alert do
              find_link('Delete Reviewer').click
            end
            pause
          end
          pause
        end.to change { grant.reviewers.reload.length }.by(-1)

        expect(page).to have_text 'Reviewer and their reviews have been deleted for this grant.'
      end

      scenario 'reviewer and their reviews can be deleted' do
        dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"
        expect do
          within('#reviewers') do
            find(dropdown_menu_id).hover
            accept_alert do
              find_link('Delete Reviewer').click
            end
            pause
          end
          pause
        end.to change { grant.reviews.reload.length }.by(-1)
      end

      scenario 'displays error when reviewer is not found' do
        dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"
        grant.grant_reviewers.first.destroy!
        within('#reviewers') do
          find(dropdown_menu_id).hover
          accept_alert do
            find_link('Delete Reviewer').click
          end
          pause
        end
        pause
        expect(page).to have_content('Reviewer could not be found or deleted.')
      end
    end

    context 'failed' do
      before do
        expect(GrantReviewerServices::DeleteReviewer).to receive(:call).and_return(OpenStruct.new(success?: false,
                                                                                                  messages: 'Unable to delete this reviewer\'s reviews.'))
      end

      scenario 'displays error messages on failure' do
        dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"

        within('#reviewers') do
          find(dropdown_menu_id).hover
          accept_alert do
            find_link('Delete Reviewer').click
          end
          pause
        end
        wait_for_ajax
        expect(page).to have_content("Unable to delete this reviewer's reviews.")
      end

      scenario 'does not change the number of reviewers' do
        expect do
          dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"

          within('#reviewers') do
            find(dropdown_menu_id).hover
            accept_alert do
              find_link('Delete Reviewer').click
            end
            pause
          end
          wait_for_ajax
        end.to_not change { grant.grant_reviewers.count }
      end

      scenario 'does not change the number of reviews' do
        expect do
          dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"

          within('#reviewers') do
            find(dropdown_menu_id).hover
            accept_alert do
              find_link('Delete Reviewer').click
            end
            pause
          end
          wait_for_ajax
        end.to_not change { grant.reviews.count }
      end
    end

    context 'paper_trail', versioning: true do
      scenario 'it tracks whodunnit' do
        grant_reviewer = GrantReviewer.find_by(grant: grant, reviewer: reviewer)
        dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"

        within('#reviewers') do
          find(dropdown_menu_id).hover
          accept_alert do
            find_link('Delete Reviewer').click
          end
          pause
        end
        wait_for_ajax
        expect(page).to have_content 'Reviewer and their reviews have been deleted for this grant.'
        expect(grant_reviewer.versions.last.whodunnit).to be grant_admin.id
      end
    end
  end
end
