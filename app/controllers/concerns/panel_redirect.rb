module PanelRedirect
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError do |e|
      if @panel.is_open? || @grant.reviewers.exclude?(current_user)
        redirect_to root_path
      else
        redirect_to grant_panel_path(@grant)
      end
    end
  end
end
