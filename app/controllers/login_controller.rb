#frozen_string_literal: true

class LoginController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    skip_policy_scope
  end
end
