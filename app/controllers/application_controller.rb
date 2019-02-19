class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!

  def user_for_paper_trail
    user_signed_in? ? current_user.id : 'Unauthenticated user'
  end
end
