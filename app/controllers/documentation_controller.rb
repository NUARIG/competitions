# frozen_string_literal: true

class DocumentationController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index; end
end
