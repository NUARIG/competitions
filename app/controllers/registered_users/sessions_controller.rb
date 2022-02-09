class  RegisteredUsers::SessionsController < Devise::SessionsController
  before_action :redirect_logged_in_user_to_root, only: :new, if: -> { user_signed_in? }
end
