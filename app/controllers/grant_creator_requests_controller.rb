# frozen_string_literal: true

class GrantCreatorRequestsController < ApplicationController
  def new
    @grant_creator_request = GrantCreatorRequest.new
    authorize @grant_creator_request
  end

  def create

  end

  def show

  end

  def update

  end
end
