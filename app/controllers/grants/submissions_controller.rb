module Grants
  class SubmissionsController < ApplicationController
    before_action :set_grant, except: :new

    def index
      @grant         = GrantDecorator.new(@grant)
      @form          = @grant.form
      @submissions   = @grant.submissions.eager_loading.where(grant_submission_form_id: @form.id)
      authorize(@grant, :edit?)
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
      # TODO: This is not the correct authorization
      authorize(@grant)
      # TODO: Make a new view
      render 'new'
    end

    def edit
      @grant = GrantDecorator.new(@grant)
      authorize(@grant, :show?)
      submission
      render 'edit'
    end

    def create
      # @grant         = Grant.friendly.find(params[:grant_id])
      authorize(@grant, :show?)
      if @grant.form.disabled
        flash[:error] = 'unable to create, this form is disabled'
        redirect_to index_page
      else
        if submission.save
          flash[:notice] = 'successfully applied'
          redirect_to grant_path(@grant)
        else
          @grant = GrantDecorator.new(@grant)
          flash[:alert] = @submission.errors.to_a
          render 'new'
        end
      end
    end

    def update
      authorize(@grant, :show?)
      if submission.update(submission_params)
        flash[:notice] = 'successfully updated response'
        #TODO: redirect based on user permissions
        redirect_to grant_submissions_path(@grant)
      else
        flash[:alert] = @submission.errors.to_a
        render 'grants/submissions/edit'
      end
    end

    def destroy
      # TODO: Policy for this
      authorize(@grant, :edit?)
      if submission.destroy
        flash[:notice] = 'Submission was deleted.'
        redirect_to grant_submissions_path(@grant)
        # flash[:error] = 'unable to delete'
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

    # def status_object
    def submission
      @submission ||=
        case action_name
        when 'new'
          # survey = @grant.surveys.includes(:sections => {:questions => :answers}).find(params[:form_builder_survey_id])
          # UPDATED: Assumes one from
          # set_grant includes everything
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
                         :document_file_name,
                         :document_content_type,
                         :document_file_size,
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
                           :document_file_name,
                           :document_content_type,
                           :document_file_size,
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
