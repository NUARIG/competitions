module Profiles
  class PanelsController < ApplicationController
    def index
      @q              = Grant.left_joins(:grant_permissions, :grant_reviewers)
                              .merge(GrantPermission.where(user: current_user))
                              .or(Grant.left_joins(:grant_permissions, :grant_reviewers)
                              .merge(GrantReviewer.where(reviewer: current_user)))
                              .kept
                              .published
                              .includes(:panel)
                              .where.not(panels: {start_datetime: nil})
                              .ransack(params[:q])

      @q.sorts        = 'panel_start_datetime desc' if @q.sorts.empty?
      @pagy_a, @grants  = pagy_array(@q.result.uniq, i18n_key: 'activerecord.models.panel')
      skip_policy_scope
    end
  end
end
