#frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if params[:SAMLResponse]
      redirect_to idp_sign_out_user_session_path
    else
      @grants = Grants::PublicDecorator.decorate_collection(Grant.public_grants)
      skip_policy_scope
    end
  end
end
