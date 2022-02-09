#frozen_string_literal: true

class LoginController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  before_action :redirect_logged_in_user_to_root, if: -> { user_signed_in? }

  def index
    skip_policy_scope
  end
end
