# frozen_string_literal: true

module Grants
  class DuplicateController < ApplicationController
    before_action :set_original_grant

    def new
      authorize @original_grant, :edit?
      @grant = GrantServices::Duplicate.call(@original_grant.id)
      @grant.valid?
      respond_to do |format|
        flash[:warning] = 'Please review and update the following information before saving.'
        format.html
      end
    end

    def create
    end

    private

    def set_original_grant
      begin
        @original_grant = Grant.find(params[:grant_id])
      rescue
        flash[:alert] = 'Grant not found.'
        redirect_to grants_path
      end
    end
  end
end
