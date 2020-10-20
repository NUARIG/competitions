module Panels
  class SubmissionsController < ApplicationController
    before_action :set_grant
    before_action :set_panel
    before_action :set_submission,  only: :show

    before_action :authorize_panel
    skip_after_action :verify_policy_scoped, only: :index

    def index
      redirect_to grant_panel_path(@grant)
    end

    def show
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
      @submission = GrantSubmission::Submission.kept.reviewed.with_applicant.with_responses.find(params[:id])
    end

    def authorize_panel
      authorize @panel, :show?
    end
  end
end
