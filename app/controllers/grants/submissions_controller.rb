module Grants
  class SubmissionsController < ApplicationController
    def index
      @grant         = Grant.friendly.find(params[:grant_id])
      # ASSUMES ONE FORM
      @form          = @grant.forms.first
      # @survey        = @grant.surveys.find(params[:form_builder_survey_id])
      @submissions = @grant.submissions.eager_loading.where(grant_submission_form_id: @form.id)
      authorize(@grant, :edit?)
      render 'index'
    end

    def new
      @grant         = Grant.friendly.find(params[:grant_id])
      submission
      # TODO: This is not the correct authorization
      authorize(@grant)
      @the_action = "Apply to #{@grant.name}"
      # TODO: Make a new view
      render 'grants/submissions/edit'
    end

    def edit
      authorize(@grant, :show?)
      submission
      @the_action = 'Edit'
      render 'grants/submission_std_answer_id/edit'
    end

    def create
      @grant         = Grant.friendly.find(params[:grant_id])
      authorize(@grant, :show?)
      if @grant.grant_forms.first.disabled
      # if @grant.grant_forms.where(submission_form: submission_csubmission.form).first.disabled
        flash[:error] = 'unable to create, this form is disabled'
        redirect_to index_page
      else
        if submission.save
          flash[:notice] = 'successfully applied'
          redirect_to grant_path(@grant)
        else
          flash[:alert] = @submission.errors.to_a
          # flash[:error] = 'unable to create'
          @the_action = 'New'
          render 'grants/submissions/edit'
        end
      end
    end

    def update
      authorize(@grant, :show?)
      if submission.update_attributes(_params[:grant_submission_submission])
        flash[:notice] = 'successfully updated response'
        redirect_to index_page
      else
        flash[:alert] = @submission.errors.to_a
        # flash[:error] = 'unable to update'
        @the_action   = 'Edit'
        render 'grants/submissions/edit'
      end
    end

    def destroy
      if !submission.available? || !submission.destroy
        flash[:error] = @submission.errors.to_a
        # flash[:error] = 'unable to delete'
      else
        flash[:notice] = 'successfully deleted response'
      end
      redirect_to index_page
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
          ## UPDATED: Assumes one from
          form   = @grant.forms.first
          rs     = @grant.submissions.build(form: form)
          rs
        when 'edit'
          rs = @grant.submissions.find(params[:id])
          rs
        when 'create'
          @grant.submissions.build(submission_params.merge(created_id: current_user.id))
        else
          @grant.submissions.find(params[:id]) if params[:id]
        end
    end

    def index_page
      polymorphic_path([@grant, FormBuilder::ResponseSet], form_builder_survey_id: submission.survey.id)
    end

    def submission_params
      params.require(:grant_submission_submission).permit(
                       :id,
                       :grant_submission_form_id,
                       :parent_id,
                       :grant_submission_section_id,
                       :baseline_id,
                       responses_attributes: [
                         :id,
                         :grant_submission_submission_id,
                         :grant_submission_question_id,
                         :grant_submission_answer_id,
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
                           :grant_submission_answer_id,
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

    def _params
      params.permit(submission_submission: [
                      :id,
                      :grant_submission_survey_id,
                      :parent_id,
                      :grant_submission_section_id,
                      :baseline_id,
                      responses_attributes: [
                        :id,
                        :grant_submission_submission_id,
                        :grant_submission_question_id,
                        :grant_submission_answer_id,
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
                        :baseline_id,
                        :_destroy,
                        responses_attributes: [
                          :id,
                          :grant_submission_submission_id,
                          :grant_submission_question_id,
                          :grant_submission_answer_id,
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
                      ]
                     ]
                    )
    end
  end
end
