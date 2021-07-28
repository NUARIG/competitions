require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantSubmission::Submission SubmissionApplicants', type: :system do
  let(:open_grant)                { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:admin)                     { open_grant.grant_permissions.role_admin.first.user }
  let(:editor)                    { open_grant.grant_permissions.role_editor.first.user }
  let(:viewer)                    { open_grant.grant_permissions.role_viewer.first.user }
  let(:submission)                { open_grant.submissions.first }
  let(:submitter)                 { submission.submitter }
  let(:sa_submitter)              { create(:grant_submission_submission_applicant,
                                            submission: submission,
                                            applicant: submitter) }
  let(:applicant)                 { submission.applicants.first }
  let(:new_applicant)             { create(:saml_user) }

  let(:draft_submission)          { create(:draft_submission_with_responses,
                                            grant: open_grant,
                                            form: open_grant.form) }
  let(:draft_sa_submitter)        { create(:grant_submission_submission_applicant,
                                            submission: draft_submission,
                                            applicant:  draft_submission.submitter) }
  let(:draft_applicant_01)        { create(:saml_user) }
  let(:draft_sa_applicant_01)     { create(:grant_submission_submission_applicant,
                                            submission: draft_submission,
                                            applicant: draft_applicant_01) }
  let(:draft_applicant_02)        { create(:saml_user) }
  let(:draft_sa_applicant_02)     { create(:grant_submission_submission_applicant,
                                            submission: draft_submission,
                                            applicant: draft_applicant_02) }

  let(:closed_grant)              { create(:closed_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:closed_admin)              { closed_grant.grant_permissions.role_admin.first.user }
  let(:closed_editor)             { closed_grant.grant_permissions.role_editor.first.user }
  let(:closed_viewer)             { closed_grant.grant_permissions.role_viewer.first.user }
  let(:closed_submission)         { closed_grant.submissions.first }
  let(:closed_submitter)          { closed_submission.submitter }
  let(:closed_sa_submitter)       { create(:grant_submission_submission_applicant,
                                            submission: closed_submission,
                                            applicant: closed_submitter) }
  let(:closed_applicant)          { closed_submission.applicants.first }

  let(:closed_draft_submission)   { create(:draft_submission_with_responses,
                                            grant: closed_grant,
                                            form: closed_grant.form) }
  let(:closed_draft_sa_submitter) { create(:grant_submission_submission_applicant,
                                            submission: closed_draft_submission,
                                            applicant:  closed_draft_submission.submitter) }
  let(:closed_draft_applicant)    { create(:saml_user) }
  let(:closed_draft_sa_applicant) { create(:grant_submission_submission_applicant,
                                            submission: closed_draft_submission,
                                            applicant: closed_draft_applicant) }


  context 'Closed Grant' do
    before(:each) do
      closed_draft_submission
      closed_draft_applicant
      closed_draft_sa_applicant
    end

    context 'Grant Admin' do
      before(:each) do
        login_as(closed_admin, scope: :saml_user)
      end

      context 'grant submissions index' do
        describe '#index', js: true do
          before(:each) do
            visit grant_submissions_path(closed_grant)
          end

          scenario 'displays applicants with a single applicant' do
            expect(page).to have_text(closed_grant.name)
            expect(page).to have_text(closed_applicant.first_name)
            expect(page).to have_text(closed_applicant.last_name)
          end
        end

        describe '#show', js: true do
          context 'single applicant with submitted submission' do
            before(:each) do
              visit grant_submission_path(closed_grant, closed_submission)
            end

            scenario 'displays applicants with a single applicant' do
              expect(page).to have_text('Applicant:')
              expect(page).to have_text(closed_applicant.first_name)
              expect(page).to have_text(closed_applicant.last_name)
            end
          end
        end

        context 'closed grant' do
          describe '#edit', js: true do
            context 'submitted submission' do
              scenario 'does not allow access to edit page' do
                visit edit_grant_submission_path(closed_grant, closed_submission)
                expect(page).to have_text('You are not authorized to perform this action.')
              end
            end

            context 'draft submission' do
              before(:each) do
                visit edit_grant_submission_path(closed_grant, closed_draft_submission)
                expect(page).to have_text('You are not authorized to perform this action.')
              end
            end
          end

          describe 'submission applicants #index', js: true do
            before(:each) do
              visit grant_submission_applicants_path(closed_grant, closed_draft_submission)
              expect(page).to have_text('You are not authorized to perform this action.')
            end
          end
        end
      end
    end

    context 'Grant Editor' do
      before(:each) do
        login_as(closed_editor, scope: :saml_user)
      end

      context 'grant submissions index' do
        describe '#index', js: true do
          before(:each) do
            visit grant_submissions_path(closed_grant)
          end

          scenario 'displays applicants with a single applicant' do
            expect(page).to have_text(closed_grant.name)
            expect(page).to have_text(closed_applicant.first_name)
            expect(page).to have_text(closed_applicant.last_name)
          end
        end

        describe '#show', js: true do
          context 'single applicant with submitted submission' do
            before(:each) do
              visit grant_submission_path(closed_grant, closed_submission)
            end

            scenario 'displays applicants with a single applicant' do
              expect(page).to have_text('Applicant:')
              expect(page).to have_text(closed_applicant.first_name)
              expect(page).to have_text(closed_applicant.last_name)
            end
          end
        end

        context 'closed grant' do
          describe '#edit', js: true do
            context 'submitted submission' do
              scenario 'does not allow access to edit page' do
                visit edit_grant_submission_path(closed_grant, closed_submission)
                expect(page).to have_text('You are not authorized to perform this action.')
              end
            end

            context 'draft submission' do
              before(:each) do
                visit edit_grant_submission_path(closed_grant, closed_draft_submission)
                expect(page).to have_text('You are not authorized to perform this action.')
              end
            end
          end

          describe 'submission applicants #index', js: true do
            before(:each) do
              visit grant_submission_applicants_path(closed_grant, closed_draft_submission)
              expect(page).to have_text('You are not authorized to perform this action.')
            end
          end
        end
      end
    end

    context 'Grant Viewer' do
      before(:each) do
        login_as(closed_viewer, scope: :saml_user)
      end

      context 'grant submissions index' do
        describe '#index', js: true do
          before(:each) do
            visit grant_submissions_path(closed_grant)
          end

          scenario 'displays applicants with a single applicant' do
            expect(page).to have_text(closed_grant.name)
            expect(page).to have_text(closed_applicant.first_name)
            expect(page).to have_text(closed_applicant.last_name)
          end
        end

        describe '#show', js: true do
          context 'single applicant with submitted submission' do
            before(:each) do
              visit grant_submission_path(closed_grant, closed_submission)
            end

            scenario 'displays applicants with a single applicant' do
              expect(page).to have_text('Applicant:')
              expect(page).to have_text(closed_applicant.first_name)
              expect(page).to have_text(closed_applicant.last_name)
            end
          end
        end

        context 'closed grant' do
          describe '#edit', js: true do
            context 'submitted submission' do
              scenario 'does not allow access to edit page' do
                visit edit_grant_submission_path(closed_grant, closed_submission)
                expect(page).to have_text('You are not authorized to perform this action.')
              end
            end

            context 'draft submission' do
              before(:each) do
                visit edit_grant_submission_path(closed_grant, closed_draft_submission)
                expect(page).to have_text('You are not authorized to perform this action.')
              end
            end
          end

          describe 'submission applicants #index', js: true do
            before(:each) do
              visit grant_submission_applicants_path(closed_grant, closed_draft_submission)
              expect(page).to have_text('You are not authorized to perform this action.')
            end
          end
        end
      end
    end

    context 'submission applicant' do
      before(:each) do
        login_as(closed_draft_applicant, scope: :saml_user)
      end

      context 'user profile submissions index' do
        describe '#index', js: true do
          before(:each) do
            visit profile_submissions_path
          end

          scenario 'displays submissions of the applicant' do
            expect(page).to have_text('My Submissions')
            expect(page).to have_text(closed_draft_submission.title)
          end
        end
      end

      describe '#show', js: true do
        context 'single applicant with submitted submission' do
          before(:each) do
            visit grant_submission_path(closed_grant, closed_draft_submission)
          end

          scenario 'displays applicants' do
            expect(page).to have_text('Applicant:')
            expect(page).to have_text(closed_draft_applicant.first_name)
            expect(page).to have_text(closed_draft_applicant.last_name)
          end
        end
      end

      context 'closed grant' do
        describe '#edit', js: true do
          context 'submitted submission' do
            scenario 'does not allow access to edit page' do
              visit edit_grant_submission_path(closed_grant, closed_submission)
              expect(page).to have_text('You are not authorized to perform this action.')
            end
          end

          context 'draft submission' do
            before(:each) do
              visit edit_grant_submission_path(closed_grant, closed_draft_submission)
              expect(page).to have_text('You are not authorized to perform this action.')
            end
          end
        end

        describe 'submission applicants #index', js: true do
          before(:each) do
            visit grant_submission_applicants_path(closed_grant, closed_draft_submission)
            expect(page).to have_text('You are not authorized to perform this action.')
          end
        end
      end
    end
  end




  context 'Open Grant' do
    before(:each) do
      draft_submission
      draft_applicant_01
      draft_sa_applicant_01
      draft_applicant_02
      draft_sa_applicant_02
    end

    context 'Grant Admin' do
      before(:each) do
        login_as(admin, scope: :saml_user)
      end

      context 'grant submissions' do
        describe '#index', js: true do
          before(:each) do
            visit grant_submissions_path(open_grant)
          end

          scenario 'displays applicants with a single applicant' do
            expect(page).to have_text(open_grant.name)
            expect(page).to have_text(applicant.first_name)
            expect(page).to have_text(applicant.last_name)
          end

          scenario 'displays applicants with multiple applicants' do
            expect(page).to have_text(open_grant.name)
            expect(page).to have_text(draft_applicant_01.first_name)
            expect(page).to have_text(draft_applicant_01.last_name)
            expect(page).to have_text(draft_applicant_02.first_name)
            expect(page).to have_text(draft_applicant_02.last_name)
          end
        end

        describe '#show', js: true do
          context 'single applicant with submitted submission' do
            before(:each) do
              visit grant_submission_path(open_grant, submission)
            end

            scenario 'displays applicants with a single applicant' do
              expect(page).to have_text('Applicant:')
              expect(page).to have_text(applicant.first_name)
              expect(page).to have_text(applicant.last_name)
            end
          end

          context 'multiple applicant with draft submission' do
            before(:each) do
              visit grant_submission_path(open_grant, draft_submission)
            end

            scenario 'displays applicants with multiple applicants' do
              expect(page).to have_text('Applicants:')
              expect(page).to have_text(draft_applicant_01.first_name)
              expect(page).to have_text(draft_applicant_01.last_name)
              expect(page).to have_text(draft_applicant_02.first_name)
              expect(page).to have_text(draft_applicant_02.last_name)
            end
          end
        end

        context 'multiple applicants on draft submission' do
          describe '#edit', js: true do
            context 'submitted submission' do
              scenario 'does not allow access to edit page' do
                visit edit_grant_submission_path(open_grant, submission)
                expect(page).to have_text('You are not authorized to perform this action.')
              end
            end

            context 'draft submission' do
              before(:each) do
                visit edit_grant_submission_path(open_grant, draft_submission)
              end

              scenario 'displays add or remove link' do
                expect(page).to have_text(draft_applicant_01.email)
                expect(page).to have_text(draft_applicant_02.email)
                expect(page).to have_link('Add or Remove Applicants', href: grant_submission_applicants_path(open_grant, draft_submission))
              end

              scenario 'add or remove link directs to the submission applicants index' do
                expect(page).to have_link('Add or Remove Applicants', href: grant_submission_applicants_path(open_grant, draft_submission))
                click_link 'Add or Remove Applicants'
                expect(current_path).to eq(grant_submission_applicants_path(open_grant, draft_submission))
              end
            end
          end

          describe 'submission applicants #index', js: true do
            before(:each) do
              visit grant_submission_applicants_path(open_grant, draft_submission)
            end

            scenario 'can remove an applicant' do
              expect(page).to have_text(draft_applicant_02.last_name)
              accept_alert do
                find('tr', id: "row_applicant_" + draft_sa_applicant_02.id.to_s).click_button("Remove")
              end
              expect(page).to have_text("#{draft_applicant_02.first_name} #{draft_applicant_02.last_name} is no longer an applicant on #{draft_submission.title}.")
              expect(page).not_to have_text(draft_applicant_02.email)
            end

            scenario 'can add an applicant' do
              new_applicant

              expect(page).not_to have_text(new_applicant.email)
              find_field(id: 'grant_submission_submission_applicant_applicant_email').set(new_applicant.email)
              click_button 'Look Up'
              expect(page).to have_text("#{new_applicant.first_name} #{new_applicant.last_name} was added as applicant on #{draft_submission.title}.")
              expect(page).to have_text(new_applicant.email)
            end
          end
        end
      end
    end

    context 'Grant Editor' do
      before(:each) do
        login_as(editor, scope: :saml_user)
      end

      context 'grant submissions' do
        describe '#index', js: true do
          before(:each) do
            visit grant_submissions_path(open_grant)
          end

          scenario 'displays applicants with a single applicant' do
            expect(page).to have_text(open_grant.name)
            expect(page).to have_text(applicant.first_name)
            expect(page).to have_text(applicant.last_name)
          end

          scenario 'displays applicants with multiple applicants' do
            expect(page).to have_text(open_grant.name)
            expect(page).to have_text(draft_applicant_01.first_name)
            expect(page).to have_text(draft_applicant_01.last_name)
            expect(page).to have_text(draft_applicant_02.first_name)
            expect(page).to have_text(draft_applicant_02.last_name)
          end
        end

        describe '#show', js: true do
          context 'single applicant with submitted submission' do
            before(:each) do
              visit grant_submission_path(open_grant, submission)
            end

            scenario 'displays applicants with a single applicant' do
              expect(page).to have_text('Applicant:')
              expect(page).to have_text(applicant.first_name)
              expect(page).to have_text(applicant.last_name)
            end
          end

          context 'multiple applicant with draft submission' do
            before(:each) do
              visit grant_submission_path(open_grant, draft_submission)
            end

            scenario 'displays applicants with multiple applicants' do
              expect(page).to have_text('Applicants:')
              expect(page).to have_text(draft_applicant_01.first_name)
              expect(page).to have_text(draft_applicant_01.last_name)
              expect(page).to have_text(draft_applicant_02.first_name)
              expect(page).to have_text(draft_applicant_02.last_name)
            end
          end
        end

        context 'multiple applicants on draft submission' do
          describe '#edit', js: true do
            context 'submitted submission' do
              scenario 'does not allow access to edit page' do
                visit edit_grant_submission_path(open_grant, submission)
                expect(page).to have_text('You are not authorized to perform this action.')
              end
            end

            context 'draft submission' do
              before(:each) do
                visit edit_grant_submission_path(open_grant, draft_submission)
              end

              scenario 'displays add or remove link' do
                expect(page).to have_text(draft_applicant_01.email)
                expect(page).to have_text(draft_applicant_02.email)
                expect(page).to have_link('Add or Remove Applicants', href: grant_submission_applicants_path(open_grant, draft_submission))
              end

              scenario 'add or remove link directs to the submission applicants index' do
                expect(page).to have_link('Add or Remove Applicants', href: grant_submission_applicants_path(open_grant, draft_submission))
                click_link 'Add or Remove Applicants'
                expect(current_path).to eq(grant_submission_applicants_path(open_grant, draft_submission))
              end
            end
          end

          describe 'submission applicants #index', js: true do
            before(:each) do
              visit grant_submission_applicants_path(open_grant, draft_submission)
            end

            scenario 'can remove an applicant' do
              expect(page).to have_text(draft_applicant_02.last_name)
              accept_alert do
                find('tr', id: "row_applicant_" + draft_sa_applicant_02.id.to_s).click_button("Remove")
              end
              expect(page).to have_text("#{draft_applicant_02.first_name} #{draft_applicant_02.last_name} is no longer an applicant on #{draft_submission.title}.")
              expect(page).not_to have_text(draft_applicant_02.email)
            end

            scenario 'can add an applicant' do
              new_applicant

              expect(page).not_to have_text(new_applicant.email)
              find_field(id: 'grant_submission_submission_applicant_applicant_email').set(new_applicant.email)
              click_button 'Look Up'
              expect(page).to have_text("#{new_applicant.first_name} #{new_applicant.last_name} was added as applicant on #{draft_submission.title}.")
              expect(page).to have_text(new_applicant.email)
            end
          end
        end
      end
    end

    context 'Grant Viewer' do
      before(:each) do
        login_as(viewer, scope: :saml_user)
      end

      context 'grant submissions index' do
        describe '#index', js: true do
          before(:each) do
            visit grant_submissions_path(open_grant)
          end

          scenario 'displays applicants with a single applicant' do
            expect(page).to have_text(open_grant.name)
            expect(page).to have_text(applicant.first_name)
            expect(page).to have_text(applicant.last_name)
          end

          scenario 'displays applicants with multiple applicants' do
            expect(page).to have_text(open_grant.name)
            expect(page).to have_text(draft_applicant_01.first_name)
            expect(page).to have_text(draft_applicant_01.last_name)
            expect(page).to have_text(draft_applicant_02.first_name)
            expect(page).to have_text(draft_applicant_02.last_name)
          end
        end

        describe '#show', js: true do
          context 'single applicant with submitted submission' do
            before(:each) do
              visit grant_submission_path(open_grant, submission)
            end

            scenario 'displays applicants with a single applicant' do
              expect(page).to have_text('Applicant:')
              expect(page).to have_text(applicant.first_name)
              expect(page).to have_text(applicant.last_name)
            end
          end

          context 'multiple applicant with draft submission' do
            before(:each) do
              visit grant_submission_path(open_grant, draft_submission)
            end

            scenario 'displays applicants with multiple applicants' do
              expect(page).to have_text('Applicants:')
              expect(page).to have_text(draft_applicant_01.first_name)
              expect(page).to have_text(draft_applicant_01.last_name)
              expect(page).to have_text(draft_applicant_02.first_name)
              expect(page).to have_text(draft_applicant_02.last_name)
            end
          end
        end

        describe 'submission applicants #index', js: true do
          scenario 'cannot edit submission applicants' do
            visit grant_submission_applicants_path(open_grant, draft_submission)
            expect(page).to have_text('You are not authorized to perform this action.')
          end
        end
      end
    end

    context 'submission applicant' do
      before(:each) do
        login_as(draft_applicant_01, scope: :saml_user)
      end

      context 'user profile submissions index' do
        describe '#index', js: true do
          before(:each) do
            visit profile_submissions_path
          end

          scenario 'displays applicants with multiple applicants' do
            expect(page).to have_text('My Submissions')
            expect(page).to have_text(draft_submission.title)
          end

          scenario 'does not display information for other submissions' do
            expect(page).not_to have_text(applicant.first_name)
            expect(page).not_to have_text(applicant.last_name)
          end

          scenario 'does not display submissions not associated with the user' do
            expect(page).not_to have_text(submission.title)
          end
        end
      end

      describe '#show', js: true do
        context 'multiple applicant with draft submission' do
          before(:each) do
            visit grant_submission_path(open_grant, draft_submission)
          end

          scenario 'displays applicants with multiple applicants' do
            expect(page).to have_text('Applicants:')
            expect(page).to have_text(draft_applicant_01.first_name)
            expect(page).to have_text(draft_applicant_01.last_name)
            expect(page).to have_text(draft_applicant_02.first_name)
            expect(page).to have_text(draft_applicant_02.last_name)
          end
        end
      end

      context 'multiple applicants on draft submission' do
        describe '#edit', js: true do
          context 'submitted submission' do
            scenario 'does not allow access to edit page' do
              visit edit_grant_submission_path(open_grant, submission)
              expect(page).to have_text('You are not authorized to perform this action.')
            end
          end

          context 'draft submission' do
            before(:each) do
              visit edit_grant_submission_path(open_grant, draft_submission)
            end

            scenario 'displays add or remove link' do
              expect(page).to have_text(draft_applicant_01.email)
              expect(page).to have_text(draft_applicant_02.email)
              expect(page).to have_link('Add or Remove Applicants', href: grant_submission_applicants_path(open_grant, draft_submission))
            end

            scenario 'add or remove link directs to the submission applicants index' do
              expect(page).to have_link('Add or Remove Applicants', href: grant_submission_applicants_path(open_grant, draft_submission))
              click_link 'Add or Remove Applicants'
              expect(current_path).to eq(grant_submission_applicants_path(open_grant, draft_submission))
            end

            describe 'submission applicants #index', js: true do
              before(:each) do
                visit grant_submission_applicants_path(open_grant, draft_submission)
              end

              scenario 'can remove an applicant' do
                expect(page).to have_text(draft_applicant_02.last_name)
                accept_alert do
                  find('tr', id: "row_applicant_" + draft_sa_applicant_02.id.to_s).click_button("Remove")
                end
                expect(page).to have_text("#{draft_applicant_02.first_name} #{draft_applicant_02.last_name} is no longer an applicant on #{draft_submission.title}.")
                expect(page).not_to have_text(draft_applicant_02.email)
              end

              scenario 'can add an applicant' do
                new_applicant

                expect(page).not_to have_text(new_applicant.email)
                find_field(id: 'grant_submission_submission_applicant_applicant_email').set(new_applicant.email)
                click_button 'Look Up'
                expect(page).to have_text("#{new_applicant.first_name} #{new_applicant.last_name} was added as applicant on #{draft_submission.title}.")
                expect(page).to have_text(new_applicant.email)
              end
            end
          end
        end
      end
    end
  end
end