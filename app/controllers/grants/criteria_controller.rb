# frozen_string_literal: true

module Grants
  class CriteriaController < GrantsController
    before_action :set_grant
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      @grant = Grant.includes(:reviews, :criteria).kept.friendly.find(params[:id])

      authorize @grant, :grant_viewer_access?

      @criteria = @grant.criteria.order(:created_at)
      # disable_fields == true when either:
      #  current_user does not have grant_editor_access permissions
      #  or
      #  there are completed reviews
      @editable = (policy(@grant).grant_editor_access? && @grant.reviews.completed.none?)
    end

    def update
      @grant = Grant.kept.friendly.find(params[:id])

      authorize @grant, :edit?

      if @grant.update(grant_params)
        flash[:notice] = 'Review form and criteria updated.'
        redirect_to criteria_grant_path(@grant)
      else
        flash.now[:alert] = @grant.errors.full_messages
        render 'index', status: :unprocessable_entity
      end
    end

    private

    def grant_params
      params.require(:grant).permit(
        :review_guidance,
        criteria_attributes: [
          :id,
          :name,
          :description,
          :is_mandatory,
          :show_comment_field,
          :_destroy]
      )
    end
  end
end
