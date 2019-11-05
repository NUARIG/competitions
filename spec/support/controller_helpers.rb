# module ControllerHelpers
RSpec.configure do |config|
  def login_system_admin
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryBot.create(:system_admin_user)
    sign_in user
    user
  end

  def login_user(user)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
      user
  end

  def login_as_user(user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end


end
