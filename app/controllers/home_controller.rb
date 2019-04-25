#frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @grants = Grants::PublicDecorator.decorate_collection(Grant.public_grants)
    skip_authorization
  end
end
