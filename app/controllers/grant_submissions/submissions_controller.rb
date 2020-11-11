module GrantSubmissions
  class SubmissionsController < GrantBaseController
    before_action :set_grant, except: %i[index new]

    def index
      @grant = Grant.kept.friendly.with_administrators.find(params[:grant_id])
      if Pundit.policy(current_user, @grant).show?
        @q       = policy_scope(GrantSubmission::Submission, policy_scope_class: GrantSubmission::SubmissionPolicy::Scope).ransack(params[:q])
        @q.sorts = 'user_updated_at desc' if @q.sorts.empty?
        @pagy, @submissions = pagy(@q.result, i18n_key: 'activerecord.models.submission')
      else
        skip_policy_scope
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
                    .includes( form:
                                { sections:
                                  { questions: :multiple_choice_options} } )
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

      if @submission.save
        @submission.update(user_updated_at: Time.now)
        @submission.submitted? ? (flash[:notice] = 'You successfully applied.') : (flash[:notice] = 'Submission was successfully saved.')
        submission_redirect(@grant, @submission)
      else
        @submission.state = 'draft'
        flash.now[:alert] = @submission.errors.to_a
        render 'new'
      end
    end

    def update
      set_submission
      authorize @submission
      @submission.user_submitted_state = params[:state]

      if @submission.update(submission_params)
        @submission.submitted? ? (flash[:notice] = 'You successfully applied.') : (flash[:notice] = 'Submission was successfully updated and saved.')
        @submission.update(user_updated_at: Time.now)
        submission_redirect(@grant, @submission)
      else
        @submission.state = 'draft'
        flash.now[:alert] = @submission.errors.to_a
        render 'edit'
      end
    end

    def destroy
      set_submission
      authorize @submission
      if @submission.destroy
        flash[:notice] = 'Submission was deleted.'
        redirect_to grant_submissions_path(@grant)
      else
        flash[:error] = @submission.errors.to_a
        redirect_back fallback_location: grant_submissions_path(@grant)
      end
    end

    private

    def set_grant
      @grant = Grant.kept.friendly.with_reviewers.with_panel.find(params[:grant_id])
    end

    def submission_redirect(grant, submission)
      if current_user == submission.applicant
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
                        form   = @grant.form
                        @grant.submissions.build(form: form)
                      when 'edit', 'update'
                        GrantSubmission::Submission.kept.find(params[:id])
                      when 'show'
                        GrantSubmission::Submission.kept.with_reviewers.find(params[:id])
                      when 'create'
                        @grant.submissions.build(submission_params.merge(created_id: current_user.id))
                      else
                        @grant.submissions.kept.find(params[:id]) if params[:id]
                      end
    end

    def submission_params
      params.require(:grant_submission_submission).permit(
                       :id,
                       :title,
                       :grant_submission_form_id,
                       :parent_id,
                       :grant_submission_section_id,
                       responses_attributes: [
                         :id,
                         :grant_submission_submission_id,
                         :grant_submission_question_id,
                         :grant_submission_multiple_choice_option_id,
                         :datetime_val_date_optional_time_magik,
                         :string_val,
                         :text_val,
                         :decimal_val,
                         :datetime_val,
                         :document,
                         :remove_document,
                         :_destroy
                       ])
    end
  end
end
