# frozen_string_literal: true

module Grants
  class DuplicateController < GrantsController
    before_action :set_original_grant, only: :new
    skip_before_action :set_grant

    def new
      authorize @original_grant, :edit?
      @grant = GrantServices::CopyAttributes.call(@original_grant.id)
      @grant.valid?
      flash[:warning] = 'Information from ' + @original_grant.name + ' has been copied below.'
      flash[:alert]   = 'Please review and update the following information.'
    end

    def create
      @original_grant = Grant.includes(:grant_permissions)
                          .friendly
                          .find(params[:grant_id])
      authorize @original_grant, :edit?

      @grant = Grant.new(grant_params)
      @grant.duplicate       = true
      @grant.organization_id = current_user.organization_id

      result = GrantServices::DuplicateDependencies.call(original_grant: @original_grant,
                                                         new_grant: @grant)

      if result.success?
        # TODO: Confirm messages the user should see
        flash[:notice]  = 'New grant based on ' + @original_grant.name + ' has been saved.'
        flash[:warning] = 'Review the information below then click "Save and Publish" to finalize.'
        redirect_to grant_grant_permissions_url(@grant)
      else
        respond_to do |format|
          flash[:alert] = result.messages
          format.html { render :new }
        end
      end
    end

    private

    def set_original_grant
      begin
        @original_grant = Grant.friendly.find(params[:grant_id])
      rescue
        flash[:alert] = 'Grant not found.'
        redirect_to grants_path
      end
    end
  end
end
