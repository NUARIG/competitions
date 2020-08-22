require 'rails_helper'

RSpec.describe 'GrantReviews', type: :system, js: true do
  let(:grant)  { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:admin)  { grant.grant_permissions.role_admin.first.user }
  let(:editor) { grant.grant_permissions.role_editor.first.user }
  let(:viewer) { grant.grant_permissions.role_viewer.first.user }
  let(:path)   { grant_reviews_path(grant) }

  let!(:review) { create(:incomplete_review, grant: grant,
                                             submission: grant.submissions.first,
                                             reviewer: grant.reviewers.first,
                                             assigner: admin) }

  context '#index' do
    describe 'submenu links' do
      context 'admin' do
        before(:each) do
          login_user(admin)
          visit grant_reviews_path(grant)
        end

        scenario 'displays link to add or assign reviewers' do
          expect(page).to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(grant)
        end

        scenario 'displays reviews xls link' do
          expect(page).to have_selector '#excel-export'
        end

        context 'incomplete reviews' do
          context 'reminders' do
            scenario 'displays link to remind reviewers' do
              expect(page).to have_link href: reminders_grant_reviews_path(grant)
            end

            scenario 'displays reminder notice' do
              find("a[href='#{reminders_grant_reviews_path(grant)}']").click
              page.driver.browser.switch_to.alert.accept()
              expect(page).to have_content 'Reviewers with incomplete reviews have been sent an email reminder'
            end
          end
        end

        context 'completed reviews' do
          before(:each) do
            complete_review(review: review)
          end

          scenario 'does not display link to remind reviewers' do
            visit grant_reviews_path(grant)
            expect(page).not_to have_link nil, href: reminders_grant_reviews_path(grant)
          end
        end

        context 'no assigned reviews' do
          before(:each) do
            review.destroy
            visit path
          end

          scenario 'displays add reviewers link' do
            expect(page).to have_link , href: grant_reviewers_path(grant)
          end

          scenario 'does not display reviews xls link' do
            expect(page).not_to have_selector '#excel-export'
          end

          scenario 'does not display reminders link' do
            expect(page).not_to have_link 'Send Reminder to Reviewers', href: reminders_grant_reviews_path(grant)
          end
        end
      end

      context 'editor' do
        before(:each) do
          login_user(editor)
          visit path
        end

        scenario 'displays link to add or assign reviewers' do
          expect(page).to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(grant)
        end

        context 'incomplete reviews' do
          scenario 'displays link to remind reviewers' do
            expect(page).to have_link 'Send Reminder to Reviewers', href: reminders_grant_reviews_path(grant)
          end
        end
      end

      context 'viewer' do
        before(:each) do
          login_user(viewer)
          visit path
        end

        scenario 'does not display link to add or assign reviewers' do
          expect(page).not_to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(grant)
        end

        scenario 'does not display link to remind reviewers' do
          expect(page).not_to have_link 'Send Reminder to Reviewers', href: reminders_grant_reviews_path(grant)
        end
      end
    end

    describe 'search' do
      before(:each) do
        login_user(admin)
      end

      context 'reset search link' do
        scenario 'does not display "reset search" link when there are no params' do
          visit path
          expect(page).not_to have_link 'Reset search', href: path
        end

        scenario 'displays "reset search" link when there is a search param' do
          visit path
          fill_in 'q_applicant_first_name_or_applicant_last_name_or_reviewer_first_name_or_reviewer_last_name_cont', with: 'Submission'
          click_button 'Search'
          expect(page).to have_link 'Reset search', href: path
        end
      end

      context 'no results' do
        scenario 'displays download all link when there are reviews' do
          visit path
          fill_in 'q_applicant_first_name_or_applicant_last_name_or_reviewer_first_name_or_reviewer_last_name_cont', with: 'supercalifragilistic'
          click_button 'Search'
          expect(page).to have_selector '#excel-export'
          expect(page.find(:xpath, "//a[@href='#{grant_reviews_path(grant, {format: 'xlsx'})}']")).not_to be nil
        end
      end
    end
  end


  def complete_review(review: )
    review.criteria_reviews.each do |criteria|
      criteria.score = random_score
      criteria.comment = Faker::Lorem.sentence
      criteria.save
    end
    review.update(overall_impact_score: random_score)
  end

  def random_score
    rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE)
  end
end
