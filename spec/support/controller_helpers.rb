# module ControllerHelpers
RSpec.configure do |config|
  def login_system_admin_saml_user
    @request.env["devise.mapping"] = Devise.mappings[:saml_user]
    user = FactoryBot.create(:system_admin_saml_user)
    sign_in user
    user
  end
end
