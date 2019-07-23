class ReviewsController < ApplicationController
  before_action :set_review,     only: %i[show edit update destroy]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.all
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    authorize @review, :show?
  end

  # GET /reviews/1/edit
  def edit
    authorize @review, :edit?
    build_criteria_reviews
  end

  # # POST /reviews
  # # POST /reviews.json
  def create
    @review = Review.new(grant_submission_submission_id: params[:submission_id],
                         reviewer_id: params[:reviewer_id],
                         assigner: current_user)
    authorize @review, :create?
    respond_to do |format|
      if @review.save
        flash[:success] = 'Submission assigned for review.'
        format.json   { head :ok }
      else
        flash[:alert] = @review.errors.full_messages
        format.json   { head :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    authorize @review, :update?
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_back fallback_location: edit_grant_submission_submission_review_path(@review, @review.submission, @review),
                                    notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        flash.now[:alert] = @review.errors.full_messages
        build_criteria_reviews
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    authorize @review, :destroy?
    @review.destroy
    respond_to do |format|
      flash[:success] = 'Review was successfully deleted.'
      format.json { head :no_content }
    end
  end

  private

  def build_criteria_reviews
    @review.grant.criteria.each do |criterion|
      unless @review.criteria_reviews.detect{ |cr| cr.criterion_id == criterion.id }.present?
        @review.criteria_reviews.build(criterion: criterion)
      end
    end
  end

  def set_review
    @review = Review.includes(:criteria, submission: :applicant).find(params[:id])
  end

  def review_params
    params.require(:review).permit(:overall_impact_score,
                                   :overall_impact_comment,
                                   criteria_reviews_attributes: [
                                    :id,
                                    :criterion_id,
                                    :score,
                                    :comment])
  end
end
