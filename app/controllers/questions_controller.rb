class QuestionsController < ApplicationController
  before_action :set_question, only: %i[show destroy]
  before_action :set_question_and_grant, only: :update
  before_action :set_question_and_grant_and_constraints, only: :edit

  def index
    @questions = Question.all
    authorize @questions
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
    authorize @question
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to grant_path(@question.grant), notice: 'Grant was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        flash[:success] = 'Question updated.'
        format.html { redirect_to edit_grant_path(@grant), notice: 'Grant was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Grant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
      authorize @question
    end

    def set_question_and_grant
      @question = Question.find(params[:id])
      @grant    = @question.grant
      authorize @question
    end

    def set_question_and_grant_and_constraints
      @question             = Question.with_constraints_and_constraint_questions.find(params[:id])
      @grant                = @question.grant
      @constraint_questions = @question.constraint_questions
      authorize @question
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(
        :name,
        :help_text,
        :placeholder_text,
        :required,
        constraint_questions_attributes: [
          :id,
          :value]
        )
    end
end
