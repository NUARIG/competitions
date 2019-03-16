module Grants
  class QuestionsController < ApplicationController
    include WithGrantRoles

    before_action :set_grant
    before_action :set_question, except: :index
    before_action :authorize_grant

    def index
      @questions = @grant.questions
    end

    def edit
    end

    def update
      if @question.update(question_params)
        # js response - edit form_with submits remote: true
        flash[:notice] = 'Question was successfully updated.'
        render js: "window.location='#{grant_questions_url(@grant)}'"
      else
        respond_to do |format|
          # see app/views/questions/update.js.erb
          flash.now[:alert] = @question.errors.full_messages
          format.js
        end
      end
    end

    private

    def set_grant
      @grant = Grant.find(params[:grant_id])
    end

    def set_question
      @question = Question.find(params[:id])
    end

    def authorize_grant
      authorize @grant, :edit?
    end

    def question_params
      params.require(:question).permit(
        :name,
        :help_text,
        :placeholder_text,
        :required,
        constraint_questions_attributes: %i[
          id
          value
        ]
      )
    end

  end
end
