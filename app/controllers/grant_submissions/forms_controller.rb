module GrantSubmissions
  class FormsController < ApplicationController
    # layout 'admin'

    before_action :set_grant
    helper_method :sort_column, :sort_direction

    # def index
    #   # authorize :admin, :view_grant_submission_forms?
    #   results = params[:search].present? ? policy_scope(FormBuilder::Survey).search_by_title(params[:search]) : policy_scope(FormBuilder::Survey)
    #   @surveys = results.order_by(sort_column, sort_direction)
    #                  # .page(params[:page]) # PAGINATION
    # end

    def new
      # authorize :admin, :manage_grant_submission_forms?
      @form = GrantSubmission::Form.new
      authorize @grant, :edit?
      # TODO: Separate new and edit views
      #render :edit
      render :new
    end

    def edit
      # authorize :admin, :view_grant_submission_forms?
      # @survey = FormBuilder::Survey.includes(:sections=>{:questions=>[:answers, :condition_group]}).find(params[:id])
      @form = GrantSubmission::Form.includes(:sections=>{:questions=>[:multiple_choice_options]}).find(params[:id])
      authorize @grant, :edit?
    end

    # def create
    #   # authorize :admin, :manage_grant_submission_forms?
    #   load_standard_answer_sets
    #   @form = GrantSubmission::Form.new(form_params)
    #   @form.created_id = current_user.id
    #   @form.updated_id = current_user.id
    #   authorize @form
    #   if @form.save
    #     flash[:notice] = 'form successfully created'
    #     redirect_to polymorphic_path(@form, action: :edit)
    #   else
    #     flash[:alert] = @form.errors.full_messages
    #     render :edit
    #   end
    # end

    def update
      # authorize :admin, :manage_grant_submission_forms?
      @form = GrantSubmission::Form.includes(sections: { questions: :multiple_choice_options }).find(params[:id])
      authorize @grant, :edit?
      if @form.available? && @form.update_attributes_safe_display_order(form_params)
      # if @survey.available? && @survey.with_safe_encoding {|o| o.update_attributes_safe_display_order(_params[:grant_submission_survey])}
        @form.updated_id = current_user.id
        @form.touch
        flash[:notice] = 'Submission Form successfully updated'
        redirect_to edit_grant_form_path(@grant, @form)
      else
        flash[:alert] = @form.errors.full_messages
        render :edit
      end
    end

    # TODO: Should be its own controller?
    def update_fields
      # authorize :admin, :manage_grant_submission_forms?
      # TODO: Figure out what to do with grant_forms
      #@form = GrantSubmission::Form.find(params[:form_id])
      @form  = @grant.form
      authorize @form, :update?
      valid_param = false
      GrantSubmission::Form::ALWAYS_EDITABLE_ATTRIBUTES.each do |field|
        if _params[:grant_submission_survey][field]
          @form[field] = _params[:grant_submission_survey][field]
          valid_param = true
        end
      end
      respond_to do |format|
        if valid_param && @form.save
          format.json { render body: nil, status: :no_content }
        else
          format.json { render json: @form.errors, status: :unprocessable_entity }
        end
      end
    end

    # def destroy
    #   # authorize :admin, :manage_grant_submission_forms?
    #   @form = GrantSubmission::Form.find(params[:id])
    #   authorize @form
    #   if !@form.destroyable? || !@form.destroy
    #     flash[:error] = 'unable to delete'
    #   else
    #     flash[:notice] = 'form successfully deleted'
    #   end
    #   redirect_to polymorphic_path(FormBuilder::Survey)
    # end

    def export
      # authorize :admin, :view_grant_submission_forms?
      @form = GrantSubmission::Form.find(params[:id])
      authorize @form, :show?
      send_data(JSON.pretty_generate(@survey.to_export_hash),
                filename: "NOTIS_eCRF_FormBuilder_Form_#{@survey.title}_#{Time.now.iso8601}.json")
    end

    # def conditions
    #   @survey = FormBuilder::Survey.find(params[:id])
    #   render :json => @survey.questions.select {|q| q.condition_group && q.condition_group.has_conditions? }.map {|q| {question_id: q.id, condition_group: q.condition_group.as_hash}}
    # end

    def import
      raise FormBuilder.new('Survey import method deleted app/controllers/grant_submission/survey_controller:110')
      # authorize :admin, :manage_grant_submission_forms?
      # ActiveRecord::Base.transaction do
      #   json = JSON.load(params[:uploaded_survey].try(:read))
      #   @survey = FormBuilder::Survey.new(json.select {|k, v| k != 'conditions'})
      #   convert_result = @survey.convert_virtual_attrs!
      #   if convert_result[:success] && @survey.with_safe_encoding(&:save)
      #     @survey.import_conditions(json)
      #     flash[:notice] = 'form successfully imported'
      #     redirect_to polymorphic_path(FormBuilder::Survey)
      #   else
      #     flash[:import_error_msg] = 'Unable to import - ' + (convert_result[:error_msg] || @survey.errors.full_messages.join('. '))
      #     redirect_to polymorphic_path(FormBuilder::Survey)
      #   end
      # end
    end

    private

    def set_grant
      @grant = Grant.friendly.find(params[:grant_id])
    end

    def sort_column
      GrantSubmission::Form::SORTABLE_FIELDS.include?(params[:sort_column]) ? params[:sort_column] : 'title'
    end

    def sort_direction
      params[:sort_direction] == 'desc' ? 'desc' : 'asc'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def form_params
      params.require(:grant_submission_form).permit(
          :title,
          :show_ans_code_in_sep_exp_col,
          :show_ans_code_in_form_entry,
          :description,
          :has_alerts,
          sections_attributes: [
            :id,
            :_destroy,
            :title,
            :display_order,
            :repeatable,
            :allow_follow_up,
            :grant_submission_form_id,
            questions_attributes: [
              :id,
              :_destroy,
              :text,
              :display_order,
              :export_code,
              :is_mandatory,
              :response_type,
              :grant_submission_std_answer_set_id,
              :instruction,
              :grant_submission_section_id,
              multiple_choice_options_attributes: [
                :id,
                :grant_submission_question_id,
                :text,
                :export_code,
                :display_order,
                :grant_submission_std_answer_id,
                :_destroy
              ]
            ]
          ]
        )
    end
  end
end
