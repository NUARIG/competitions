# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :set_question, only: %i[show destroy]
  before_action :set_question_and_grant, only: :update
  before_action :set_question_and_grant_and_constraints, only: :edit

  def index
    @questions = Question.all
    authorize @questions
  end

  # GET /questions/new
  def new
    @question = Question.new
    authorize @question
  end

  # GET /questions/1/edit
  def edit
    authorize @question
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    authorize @question
    respond_to do |format|
      if @question.update(question_params)
        # js response - edit form_with submits remote: true
        format.js { redirect_to edit_grant_path(@grant), notice: 'Question was successfully updated.' }
      else
        # see app/views/questions/update.js.erb
        flash.now[:alert] = @question.errors.full_messages
        format.js
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    authorize @question
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_question
    @question = Question.find(params[:id])
  end

  def set_question_and_grant
    @question = Question.find(params[:id])
    @grant    = @question.grant
  end

  def set_question_and_grant_and_constraints
    @question             = Question.with_constraints_and_constraint_questions.find(params[:id])
    @grant                = @question.grant
    @constraint_questions = @question.constraint_questions
  end

  # Never trust parameters from the scary internet, only allow the white list through.
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
