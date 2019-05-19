module Grants
  class ApplyController < ApplicationController
    before_action :set_grant, except: :index

    def new
      response_set
      # TODO: This is not the correct authorization
      authorize(@grant)
      @the_action = "Apply to #{@grant.name}"
      # TODO: Make a new view
      render 'grants/apply/edit'
    end

    def edit
      authorize(@grant, :show?)
      response_set
      @the_action = 'Edit'
      render 'grants/apply/edit'
    end

    def create
      authorize(@grant, :show?)
      byebug
      if @grant.grant_forms.first.disabled
      # if @grant.grant_forms.where(submission_form: submission_cresponse_set.form).first.disabled
        flash[:error] = 'unable to create, this form is disabled'
        redirect_to index_page
      else
        if response_set.save
          flash[:notice] = 'successfully applied'
          redirect_to grant_path(@grant)
        else
          flash[:alert] = @response_set.errors.to_a
          # flash[:error] = 'unable to create'
          @the_action = 'New'
          render 'grants/apply/edit'
        end
      end
    end

    def update
      authorize(@grant, :show?)
      if response_set.update_attributes(_params[:form_builder_response_set])
        flash[:notice] = 'successfully updated response'
        redirect_to index_page
      else
        flash[:alert] = @response_set.errors.to_a
        # flash[:error] = 'unable to update'
        @the_action   = 'Edit'
        render 'form_builder/response_sets/edit'
      end
    end

    def destroy
      if !response_set.available? || !response_set.destroy
        flash[:error] = @response_set.errors.to_a
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
    def response_set
      @response_set ||=
        case action_name
        when 'new'
          # survey = @grant.surveys.includes(:sections => {:questions => :answers}).find(params[:form_builder_survey_id])
          ## UPDATED: Assumes one from
          form   = @grant.forms.first
          rs     = @grant.response_sets.build(form: form)
          rs
        when 'edit'
          rs = @grant.response_sets.find(params[:id])
          rs
        when 'create'
          byebug
          @grant.response_sets.build(response_set_params.merge(created_id: current_user.id))
        else
          @grant.response_sets.find(params[:id]) if params[:id]
        end
    end

    def index_page
      polymorphic_path([@grant, FormBuilder::ResponseSet], form_builder_survey_id: response_set.survey.id)
    end

    def response_set_params
      params.require(:submission_response_set).permit(
                       :id,
                       :submission_form_id,
                       :parent_id,
                       :submission_section_id,
                       :baseline_id,
                       responses_attributes: [
                         :id,
                         :submission_response_set_id,
                         :submission_question_id,
                         :submission_answer_id,
                         :datetime_val_date_optional_time_magik,
                         :submission_std_answer_id,
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
                         :submission_section_id,
                         :_destroy,
                         responses_attributes: [
                           :id,
                           :submission_response_set_id,
                           :submission_question_id,
                           :submission_answer_id,
                           :datetime_val_date_optional_time_magik,
                           :submission_std_answer_id,
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
      params.permit(submission_response_set: [
                      :id,
                      :submission_survey_id,
                      :parent_id,
                      :submission_section_id,
                      :baseline_id,
                      responses_attributes: [
                        :id,
                        :submission_response_set_id,
                        :submission_question_id,
                        :submission_answer_id,
                        :datetime_val_date_optional_time_magik,
                        :submission_std_answer_id,
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
                        :submission_section_id,
                        :baseline_id,
                        :_destroy,
                        responses_attributes: [
                          :id,
                          :submission_response_set_id,
                          :submission_question_id,
                          :submission_answer_id,
                          :datetime_val_date_optional_time_magik,
                          :submission_std_answer_id,
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
