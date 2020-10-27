module Profiles
  class SubmissionsController < ApplicationController
    def index
      @q = current_user.submissions.kept.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @pagy, @submissions = pagy(@q.result, i18n_key: 'activerecord.models.submission')
      skip_policy_scope
    end
  end
end
