module Panels
  class SubmissionsController < ApplicationController
    include PanelRedirect

    before_action :set_grant
    before_action :set_panel
    before_action :set_submission,  only: :show
    skip_after_action :verify_policy_scoped, only: :index

    # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def index
      authorize @panel, :show?
      redirect_to grant_panel_path(@grant)
    end

    def show
      authorize @panel, :view_content?
      render :show
    end

    private

    def set_grant
      @grant = Grant.kept.friendly.find(params[:grant_id])
    end

    def set_panel
      @panel = @grant.panel
    end

    def set_submission
      @submission = GrantSubmission::Submission.kept.reviewed.with_submitter.with_responses.find(params[:id])
    end
  end
end
