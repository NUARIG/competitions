require 'rails_helper'

RSpec.describe 'Panels', type: :system, js: true do
  let(:grant)       { create(:published_closed_grant_with_users) }
  let(:admin)       { grant.admins.first  }
  let(:editor)      { grant.editors.first }
  let(:viewer)      { grant.viewers.first }
  let(:reviewer)    { grant.reviewers.first }
  let(:applicant)   { grant.applicants.first }
  let(:button_text) { 'Update Panel Information' }
  let(:review)      { create(:scored_review_with_scored_mandatory_criteria_review,
                                submission: grant.submissions.first,
                                assigner: admin,
                                reviewer: reviewer)}

  let(:unreviewed_submission) { create(:submission_with_responses,
                                        grant: grant,
                                        form: grant.form,
                                        state: 'submitted',
                                        user_updated_at: grant.submission_close_date - 2.minutes) }
  let(:draft_submission)      { create(:draft_submission_with_responses,
                                        grant: grant,
                                        form: grant.form,
                                        user_updated_at: grant.submission_close_date - 1.minute) }
  let(:reviewed_submission)   { create(:reviewed_submission,  grant: grant,
                                                              form: grant.form) }

  describe 'Edit' do
    context 'user' do
      context 'with grant_permission' do
        context 'grant_admin' do
          scenario 'can visit the edit page' do
            login_user admin
            can_vist_edit_page(user: admin)
          end
        end

        context 'grant_editor' do
          scenario 'can visit the edit page' do
            login_user admin
            can_vist_edit_page(user: editor)
          end
        end

        context 'grant_viewer' do
          scenario 'cannot visit the edit page' do
            login_user viewer
            cannot_vist_edit_page(user: viewer)
          end
        end

        context 'grant_viewer' do
          scenario 'cannot visit the edit page' do
            login_user applicant
            cannot_vist_edit_page(user: applicant)
          end
        end

      end
    end
  end

  describe 'Update' do
    context 'user' do
      context 'with grant_permission' do
        context 'grant_admin' do
          before(:each) do
            login_user admin
            # visit edit_grant_panel_path(grant)
          end

          scenario 'may update' do
            can_update_panel(user: admin)
          end
        end

        context 'grant_editor' do
          before(:each) do
            login_user editor
          end

          scenario 'may update' do
            can_update_panel(user: editor)
          end
        end
      end
    end

    context 'instructions' do
      before(:each) do
        login_user admin
        visit edit_grant_panel_path(grant)
      end

      scenario 'updates' do
        new_instructions = Faker::Lorem.sentence(word_count: 8)
        fill_in_trix_editor('panel_instructions', with: new_instructions)
        click_button button_text
        expect(page).to have_content 'Panel information successfully updated.'
        expect(grant.panel.instructions).to have_content new_instructions
      end
    end

    context 'meeting_link' do
      before(:each) do
        login_user admin
        visit edit_grant_panel_path(grant)
      end

      scenario 'requires https' do
        page.fill_in 'Meeting Link', with: Faker::Internet.url(scheme: 'http')
        click_button button_text
        expect(page).to have_content 'not a valid secure URL'
      end
    end

    context 'dates' do
      before(:each) do
        login_user admin
        visit edit_grant_panel_path(grant)
      end

      context 'start_datetime' do
        scenario 'required to be before grant submission_close_date' do
          invalid_start = (grant.submission_close_date - 1.day).at_noon
          expect do
            page.fill_in 'Start Date/Time', with: ''
            page.fill_in 'Start Date/Time', with: invalid_start.strftime("%m/%d/%Y %H:%M%P")
            click_button button_text
          end.not_to change{grant.panel.reload.start_datetime}
          expect(page).to have_content I18n.t('activerecord.errors.models.panel.attributes.start_datetime.before_submission_deadline')
        end

        scenario 'required to be before end_datetime' do
          invalid_start = Date.tomorrow.at_noon
          invalid_end   = Date.today.at_noon
          expect do
            page.fill_in 'Start Date/Time', with: ''
            page.fill_in 'Start Date/Time', with: invalid_start.strftime("%m/%d/%Y %H:%M%P")
            page.fill_in 'End Date/Time',   with: ''
            page.fill_in 'End Date/Time',   with: invalid_end.strftime("%m/%d/%Y %H:%M%P")
            click_button button_text
          end.not_to change{grant.panel.reload.start_datetime}
          expect(page).to have_content 'must be before End Date/Time'
        end
      end
    end

    context 'paper_trail', versioning: true do
      scenario 'it tracks whodunnit' do
        login_user editor
        visit edit_grant_panel_path(grant)
        fill_in 'Meeting Location', with: 'Edited'
        click_button button_text
        expect(grant.panel.versions.last.whodunnit).to eql editor.id
      end
    end
  end

  describe 'Show' do
    before(:each) do
      review.save
      login_user grant.editors.first
    end

    context 'banner' do
      context 'panel is open' do
        context 'close is today' do
          scenario 'banner does not include date' do
            grant.panel.update(start_datetime: 1.hour.ago, end_datetime: 1.minute.from_now)

            visit grant_panel_path(grant)
            expect(page).to have_content(panel_time_portion(panel: grant.panel, which_date: 'end'))
            expect(page).not_to have_content(panel_date_portion(panel: grant.panel, which_date: 'end'))
          end
        end

        context 'close is tomorrow' do
          scenario 'banner includes date' do
            grant.panel.update(start_datetime: 1.hour.ago, end_datetime: 1.day.from_now)
            visit grant_panel_path(grant)
            expect(page).to have_content(panel_time_portion(panel: grant.panel, which_date: 'end'))
            expect(page).to have_content(panel_date_portion(panel: grant.panel, which_date: 'end'))
          end
        end
      end
    end

    context 'metadata' do
      scenario 'instructions' do
        visit grant_panel_path(grant)
        expect(page).to have_content grant.panel.instructions
      end

      context 'meeting_location' do
        scenario 'displays when set' do
          visit grant_panel_path(grant)
          expect(page.has_css?('.location')).to be true
          expect(page).to have_content grant.panel.meeting_location.html_safe
        end

        scenario 'excluded when not set' do
          grant.panel.update(meeting_location: nil)
          visit grant_panel_path(grant)
          expect(page.has_css?('.location')).to be false
          expect(page).not_to have_content 'Location:'
        end
      end

      context 'meeting_link' do
        scenario 'displays when set' do
          visit grant_panel_path(grant)
          expect(page.has_css?('.link')).to be true
          expect(page).to have_link grant.panel.meeting_link, href: grant.panel.meeting_link
        end

        scenario 'excluded when not set' do
          grant.panel.update(meeting_link: nil)
          visit grant_panel_path(grant)
          expect(page.has_css?('.link')).to be false
        end
      end
    end

    context 'submissions' do
      scenario 'does not include draft submission' do
        draft_submission.save
        visit grant_panel_path(grant)

        expect(page).to have_content grant.submissions.first.title
        expect(page).not_to have_content draft_submission.title
      end

      scenario 'does not include unreviewed submitted submission' do
        unreviewed_submission.save
        visit grant_panel_path(grant)

        expect(page).to have_content grant.submissions.first.title
        expect(page).not_to have_content unreviewed_submission.title
      end
    end
  end

  describe 'sorts' do
    before(:each) do
      @high_scored_submission = review.submission
      @high_scored_submission.update(title: "AAA #{Faker::Lorem.sentence}")
      @high_scored_submission.applicant.update(last_name: 'AAA')
      @high_scored_submission.reviews.first.update(overall_impact_score: Review::MAXIMUM_ALLOWED_SCORE)
      @high_scored_submission.reviews.first.criteria_reviews.each{ |r| r.update(score: Review::MAXIMUM_ALLOWED_SCORE,
                                                                         updated_at: grant.review_close_date - 1.minute) }

      @low_scored_submission  = create(:reviewed_submission, grant: grant, form: grant.form, title: "ZZZ #{Faker::Lorem.sentence}")
      @low_scored_submission.applicant.update(last_name: 'ZZZ')
      @low_scored_submission.reviews.first.update(overall_impact_score: Review::MINIMUM_ALLOWED_SCORE)
      @low_scored_submission.reviews.first.criteria_reviews.each{ |r| r.update(score: Review::MINIMUM_ALLOWED_SCORE,
                                                                        updated_at: grant.review_close_date - 1.minute) }

      login_user grant.editors.first
      visit grant_panel_path(grant)
    end

    context 'overall impact' do
      scenario 'defaults to overall impact score asc' do
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @low_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @high_scored_submission.title
        end
      end

      scenario 'reverse sorts on overall impact score' do
        visit grant_panel_path(grant)
        click_link 'Overall Impact'
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @high_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @low_scored_submission.title
        end

        click_link 'Overall Impact'
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @low_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @high_scored_submission.title
        end
      end
    end

    context 'composite' do
      scenario 'sorts on composite score' do
        visit grant_panel_path(grant)

        # ascending first
        click_link 'Composite'
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @low_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @high_scored_submission.title
        end

        # descending
        click_link 'Composite'
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @high_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @low_scored_submission.title
        end
      end
    end

    context 'applicant last_name' do
      scenario 'sorts on last_name' do
        visit grant_panel_path(grant)

        # ascending first
        click_link 'Applicant'
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @high_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @low_scored_submission.title
        end

        # descending
        click_link 'Applicant'
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @low_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @high_scored_submission.title
        end
      end
    end

    context 'submission title' do
      scenario 'sorts on title' do
        visit grant_panel_path(grant)

        # ascending first
        click_link 'Submission'
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @high_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @low_scored_submission.title
        end

        # descending
        click_link 'Submission'
        within 'tr.submission:nth-child(1)' do
          expect(page).to have_text @low_scored_submission.title
        end
        within 'tr.submission:nth-child(2)' do
          expect(page).to have_text @high_scored_submission.title
        end
      end
    end
  end

  def can_vist_edit_page(user:)
    visit edit_grant_panel_path(grant)

    expect(page).not_to have_content 'You are not authorized to perform this action.'
  end

  def cannot_vist_edit_page(user:)
    visit edit_grant_panel_path(grant)

    expect(page).to have_content 'You are not authorized to perform this action.'
  end

  def can_update_panel(user:)
    visit edit_grant_panel_path(grant)
    new_address = Faker::Address.full_address
    page.fill_in 'Meeting Location', with: new_address, fill_options: { clear: :backspace }
    click_button button_text
    expect(page).to have_content 'Panel information successfully updated.'
    expect(grant.panel.meeting_location).to eql new_address
  end

  def panel_time_portion(panel:, which_date:)
    open_or_close = "#{which_date}_datetime"
    panel.send(open_or_close).strftime('%l:%M%P')
  end

  def panel_date_portion(panel:, which_date:)
    open_or_close = "#{which_date}_datetime"
    "on #{panel.send(open_or_close).strftime('%-m/%-d/%Y')}"
  end
end
