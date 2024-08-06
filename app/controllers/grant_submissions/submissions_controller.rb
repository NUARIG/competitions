module GrantSubmissions
  class SubmissionsController < GrantBaseController
    before_action :set_grant, except: %i[index new]
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      flash.keep
      @grant = Grant.kept.friendly.with_administrators.find(params[:grant_id])
      set_user_grant_role

      if @user_grant_role.present?
        @q       = GrantSubmission::Submission.kept.includes(:reviews, :applicants,
                                                             :grant).where(grant_id: @grant.id).ransack(params[:q])
        @q.sorts = 'user_updated_at desc' if @q.sorts.empty?

        @pagy, @submissions = pagy_array(@q.result.to_a.uniq, i18n_key: 'activerecord.models.submission')
      else
        flash[:alert] = I18n.t('pundit.default')
        redirect_to root_path
      end
    end

    def show
      set_submission
      authorize @submission
      render 'show'
    end

    def new
      @grant = Grant.kept
                    .friendly
                    .includes(:contacts, form: { sections: { questions: :multiple_choice_options } })
                    .with_reviewers.with_panel
                    .find(params[:grant_id])
      set_submission
      authorize @submission
      render 'new'
    end

    def edit
      set_submission
      authorize @submission
      render 'edit'
    end

    def create
      set_submission
      authorize @submission
      @submission.user_submitted_state = params[:state]
      result = GrantSubmissionSubmissionServices::New.call(submission: @submission)

      if result.success?
        @submission.update(user_updated_at: Time.now)
        if @submission.submitted?
          send_notifications
          flash[:notice] = 'You successfully applied.'
        else
          flash[:warning] =
            'Draft submission was saved. <strong>It can not be reviewed until it has been submitted</strong>.'.html_safe
        end
        submission_redirect(@grant, @submission)
      else
        @submission.state = 'draft'
        flash[:alert] = result.messages
        render 'new'
      end
    end

    def update
      set_submission
      authorize @submission
      set_user_grant_role

      @submission.user_submitted_state = params[:state]

      if @submission.update(submission_params)
        if @submission.submitted?
          send_notifications
          flash[:notice] = 'You successfully applied.'
        else
          flash[:warning] =
            'Draft submission was successfully updated and saved. <strong>It can not be reviewed until it has been submitted</strong>.'.html_safe
        end
        @submission.update(user_updated_at: Time.now)
        submission_redirect(@grant, @submission)
      else
        @submission.state = 'draft'
        flash.now[:alert] = @submission.errors.to_a
        render 'edit', status: :unprocessable_entity
      end
    end

    def destroy
      set_submission
      authorize @submission
      if @submission.destroy
        flash[:notice] = 'Submission was deleted.'
        redirect_to grant_submissions_path(@grant)
      else
        flash.now[:error] = @submission.errors.to_a
        redirect_back fallback_location: grant_submissions_path(@grant)
      end
    end

    private

    def set_grant
      @grant = Grant.includes(:contacts).kept.friendly.with_reviewers.with_panel.find(params[:grant_id])
    end

    def submission_redirect(grant, submission)
      if submission.has_applicant?(current_user)
        redirect_to profile_submissions_path
      elsif current_user.get_role_by_grant(grant: grant)
        redirect_to grant_submissions_path(grant)
      else
        redirect_to root_path
      end
    end

    def set_submission
      @submission ||= case action_name
                      when 'new'
                        form = @grant.form
                        @grant.submissions.build(form: form)
                      when 'edit', 'update'
                        GrantSubmission::Submission.kept.with_applicants.find(params[:id])
                      when 'show'
                        GrantSubmission::Submission.kept.with_reviewers.find(params[:id])
                      when 'create'
                        @grant.submissions.build(submission_params.merge(created_id: current_user.id))
                      else
                        @grant.submissions.kept.find(params[:id]) if params[:id]
                      end
    end

    def send_notifications
      # add any others here
      send_grant_admin_notifications if grant_admin_notification_recipients.any?
    end

    def grant_admin_notification_recipients
      @admin_notification_emails = helpers.admin_submission_notification_emails(grant: @grant)
    end

    def send_grant_admin_notifications
      GrantPermissionMailers::SubmissionMailer
        .submitted_notification(grant: @grant,
                                recipients: @admin_notification_emails,
                                submission: @submission)
        .deliver_now
    end

    def set_user_grant_role
      @user_grant_role = current_user.get_role_by_grant(grant: @grant)
    end

    def submission_params
      params.require(:grant_submission_submission).permit(
        :id,
        :title,
        :grant_submission_form_id,
        :parent_id,
        :grant_submission_section_id,
        responses_attributes: %i[
          id
          grant_submission_submission_id
          grant_submission_question_id
          grant_submission_multiple_choice_option_id
          datetime_val_date_optional_time_magik
          string_val
          text_val
          decimal_val
          datetime_val
          document
          remove_document
          _destroy
        ],
        submission_applicants_attributes: %i[
          id
          grant_submission_submission_id
          applicant_id
        ]
      )
    end
  end
end
