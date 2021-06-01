# frozen_string_literal: true

module Grants
  class CriteriaController < GrantsController
    before_action :set_grant
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      authorize @grant, :grant_viewer_access?
      @criteria = @grant.criteria.order(:created_at)
    end

    def update
      authorize @grant, :edit?
      if @grant.update(grant_params)
        flash[:notice] = 'Grant updated'
        redirect_to criteria_grant_path(@grant)
      else
        flash.now[:alert] = @grant.errors.full_messages
        render 'index'
      end
    end

    private

    def set_grant
      @grant = Grant.kept.friendly.find(params[:id])
    end

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
