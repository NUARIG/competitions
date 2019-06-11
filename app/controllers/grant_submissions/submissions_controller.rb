module GrantSubmissions
  class SubmissionsController < GrantBaseController
    before_action :set_grant, except: :new

    def index
      @grant         = GrantDecorator.new(@grant)
      @form          = @grant.form
      @submissions   = @grant.submissions.eager_loading.where(grant_submission_form_id: @form.id)
      @submissions   = policy_scope(GrantSubmission::Submission,
                                    policy_scope_class: GrantSubmission::SubmissionPolicy::Scope)

      render 'index'
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
      if @grant.form.disabled
        flash[:error] = 'unable to create, this form is disabled'
        redirect_to index_page
      else
        submission
        authorize @submission
        if @submission.save
          flash[:notice] = 'successfully applied'
          redirect_to grant_path(@grant)
        else
          @grant = GrantDecorator.new(@grant)
          flash.now[:alert] = @submission.errors.to_a
          render 'new'
        end
      end
    end

    def update
      submission
      authorize @submission
      if @submission.update(submission_params)
        flash[:notice] = 'Submission was successfully updated'
        #TODO: redirect based on user permissions
        redirect_to grant_submissions_path(@grant)
      else
        flash.now[:alert] = @submission.errors.to_a
        render 'grants/submissions/edit'
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

    # def download_document
    #   response = FormBuilder::Response.find(params[:form_builder_response_id])
    #   send_file response.document.path
    # end

    private

    def set_grant
      @grant = Grant.friendly.find(params[:grant_id])
    end

    def submission
      @submission ||= case action_name
                      when 'new'
                        form   = @grant.form # .includes(sections: { questions: :multiple_choice_options }).first
                        @grant.submissions.build(form: form)
                      when 'edit', 'show'
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
                       :baseline_id,
                       responses_attributes: [
                         :id,
                         :grant_submission_submission_id,
                         :grant_submission_question_id,
                         :grant_submission_multiple_choice_option_id,
                         :datetime_val_date_optional_time_magik,
                         :grant_submission_std_answer_id,
                         :string_val,
                         :text_val,
                         :decimal_val,
                         :datetime_val,
                         :boolean_val,
                         :document,
                         :'partial_date_val_virtual(1i)',
                         :'partial_date_val_virtual(2i)',
                         :'partial_date_val_virtual(3i)',
                         :partial_date_val,
                         :_destroy
                       ],
                       children_attributes: [
                         :id,
                         :grant_submission_section_id,
                         :_destroy,
                         responses_attributes: [
                           :id,
                           :grant_submission_submission_id,
                           :grant_submission_question_id,
                           :grant_submission_multiple_choice_option_id,
                           :datetime_val_date_optional_time_magik,
                           :grant_submission_std_answer_id,
                           :string_val,
                           :text_val,
                           :decimal_val,
                           :datetime_val,
                           :boolean_val,
                           :document,
                           :'partial_date_val_virtual(1i)',
                           :'partial_date_val_virtual(2i)',
                           :'partial_date_val_virtual(3i)',
                           :partial_date_val,
                           :_destroy
                         ]
                       ]
      )
    end
  end
end
