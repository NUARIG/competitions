module GrantSubmissions
  class SubmissionsController < GrantBaseController
    before_action :set_grant, except: :new

    def index
      @grant   = GrantDecorator.new(@grant)
      @q       = policy_scope(GrantSubmission::Submission, policy_scope_class: GrantSubmission::SubmissionPolicy::Scope).ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @pagy, @submissions = pagy(@q.result, i18n_key: 'activerecord.models.submission')
    end

    def show
      submission
      authorize @submission
      @grant = GrantDecorator.new(@grant)
      render 'show'
    end

    def new
      @grant = Grant.friendly
                    .includes(form:
                                { sections:
                                  {questions: :multiple_choice_options} }
                              )
                    .find(params[:grant_id])
      @grant = GrantDecorator.new(@grant)
      submission
      authorize @submission
      render 'new'
    end

    def edit
      @grant = GrantDecorator.new(@grant)
      submission
      authorize @submission
      render 'edit'
    end

    def create
      submission
      authorize @submission
      set_state(@submission)
      if @submission.save(context: @submission.state.to_sym)
        flash[:notice] = 'You successfully applied'
        if current_user == @submission.applicant
          redirect_to profile_submissions_path
        elsif current_user.get_role_by_grant(grant: @grant)
          redirect_to grant_submissions_path(@grant)
        else
          redirect_to root_path
        end
      else
        @submission.state = 'draft'
        @grant = GrantDecorator.new(@grant)
        flash.now[:alert] = @submission.errors.to_a
        render 'new'
      end
    end

    def update
      submission
      authorize @submission
      set_state(@submission)
      @submission.assign_attributes(submission_params)
      if @submission.save(context: @submission.state.to_sym)
        flash[:notice] = 'Submission was successfully updated'
        if current_user == @submission.applicant
          redirect_to profile_submissions_path
        elsif current_user.get_role_by_grant(grant: @grant)
          redirect_to grant_submissions_path(@grant)
        else
          redirect_to root_path
        end
      else
        @submission.state = 'draft'
        @grant = GrantDecorator.new(@grant)
        flash.now[:alert] = @submission.errors.to_a
        render 'edit'
      end
    end

    def destroy
      submission
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
      @grant = Grant.friendly.find(params[:grant_id])
    end

    def set_state(submission)
      if saved_as_draft?
        submission.state = 'draft'
        # submission.update(state: 'draft')
      elsif submitted?
        submission.state = 'submitted'
        submission.submitted_at = Time.now
        # submission.update(state: 'submitted', submitted_at: Time.now)
      else
        flash[:error] = submission.errors.to_a
        redirect_back fallback_location: grant_submissions_path(@grant)
      end
    end

    def saved_as_draft?
      params[:commit] == "Save as Draft"
    end

    def submitted?
      params[:commit] == "Submit"
    end

    def submission
      @submission ||= case action_name
                      when 'new'
                        form   = @grant.form
                        @grant.submissions.build(form: form)
                      when 'edit', 'show', 'update'
                        @grant.submissions.find(params[:id])
                      when 'create'
                        @grant.submissions.build(submission_params.merge(created_id: current_user.id))
                      else
                        @grant.submissions.find(params[:id]) if params[:id]
                      end
    end

    def submission_params
      params.require(:grant_submission_submission).permit(
                       :id,
                       :title,
                       :grant_submission_form_id,
                       :parent_id,
                       :grant_submission_section_id,
                       :state,
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
