module GrantSubmissions
  class FormsController < ApplicationController
    before_action :set_grant
    helper_method :sort_column, :sort_direction

    def edit
      @form = GrantSubmission::Form.includes(:sections=>{:questions=>[:multiple_choice_options]}).find(params[:id])
      authorize @form
    end

    def update
      @form = GrantSubmission::Form.find(params[:id])

      authorize @form
      if @form.available? && @form.update_attributes_safe_display_order(form_params)
        @form.updated_id = current_user.id
        @form.touch
        flash[:notice] = 'Submission Form successfully updated'
        redirect_to edit_grant_form_path(@grant, @form)
      else
        flash.now[:alert] = @form.errors.full_messages
        render :edit
      end
    end

    private

    def set_grant
      @grant = Grant.friendly.find(params[:grant_id])
    end

    def form_params
      params.require(:grant_submission_form).permit(
          :submission_instructions,
          sections_attributes: [
            :id,
            :_destroy,
            :title,
            :display_order,
            :grant_submission_form_id,
            questions_attributes: [
              :id,
              :_destroy,
              :text,
              :display_order,
              :is_mandatory,
              :response_type,
              :instruction,
              :grant_submission_section_id,
              multiple_choice_options_attributes: [
                :id,
                :grant_submission_question_id,
                :text,
                :display_order,
                :_destroy
              ]
            ]
          ]
        )
    end
  end
end
