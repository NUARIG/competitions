module Grants
  class SubmissionsController < ApplicationController
    def index
      @grant         = Grant.friendly.find(params[:grant_id])
      # ASSUMES ONE FORM
      @form          = @grant.forms.first
      # @survey        = @grant.surveys.find(params[:form_builder_survey_id])
      @response_sets = @grant.response_sets.eager_loading.where(submission_form_id: @form.id)
      authorize(@grant, :edit?)
      render 'index'
    end
  end
end
