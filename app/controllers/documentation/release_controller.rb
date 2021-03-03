#frozen_string_literal: true

module Documentation
  class ReleaseController < ApplicationController
    skip_before_action :authenticate_user!, only: :index

    def index
      skip_policy_scope
    end
  end
end