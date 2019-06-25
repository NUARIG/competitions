# # frozen_string_literal: true

# class CriteriaController < GrantsController

#   before_action :set_grant
#   skip_after_action :verify_policy_scoped, only: %i[index]

#   def index
#     authorize @grant, :grant_viewer_access?
#     @criteria = @grant.criteria.order(:id)
#   end

#   private

#   def set_grant
#     @grant = Grant.not_deleted.with_organization.friendly.find(params[:grant_id])
#   end
# end
