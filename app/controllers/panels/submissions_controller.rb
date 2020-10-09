module Panels
  class SubmissionsController < ApplicationController
    before_action :set_grant
    before_action :set_panel
    before_action :set_submission

    def show
      authorize @panel, :show?
    end

    private

    def set_grant
      @grant = Grant.kept.friendly.find(params[:grant_id])
    end

    def set_panel
      @panel = @grant.panel
    end

    def set_submission
      @submission = GrantSubmission::Submission.kept.find(params[:id])
    end

  end
end
