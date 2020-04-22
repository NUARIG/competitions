# frozen_string_literal: true

module Grants
  class DuplicateController < GrantsController
    before_action :set_original_grant, only: :new
    skip_before_action :set_grant

    def new
      authorize @original_grant, :duplicate?
      @grant = GrantServices::CopyAttributes.call(@original_grant.id)
      @grant.valid?
      flash.now[:warning] = 'Information from ' + @original_grant.name + ' has been copied below.'
    end

    def create
      @original_grant = Grant.includes(:grant_permissions)
                          .friendly
                          .find(params[:grant_id])
      authorize @original_grant, :duplicate?

      @grant = Grant.new(grant_params)
      @grant.duplicate       = true

      result = GrantServices::DuplicateDependencies.call(original_grant: @original_grant,
                                                         new_grant: @grant)

      if result.success?
        # TODO: Confirm messages the user should see
        flash[:notice]  = 'New grant based on ' + @original_grant.name + ' has been saved.'
        flash[:warning] = 'Review the information below then click "Save and Publish" to finalize.'
        redirect_to grant_grant_permissions_url(@grant)
      else
        flash.now[:alert] = result.messages
        render 'new'
      end
    end

    private

    def set_original_grant
      begin
        @original_grant = Grant.kept
                               .friendly
                               .includes(form: { sections: :questions } )
                               .find(params[:grant_id])
      rescue
        flash[:alert] = 'Grant not found.'
        redirect_to grants_path
      end
    end
  end
end
