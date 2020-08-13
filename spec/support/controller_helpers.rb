# module ControllerHelpers
RSpec.configure do |config|
  def login_system_admin_saml_user
    @request.env["devise.mapping"] = Devise.mappings[:saml_user]
    user = FactoryBot.create(:system_admin_saml_user)
    sign_in user
    user
  end

  def login_saml_user
    @request.env["devise.mapping"] = Devise.mappings[:saml_user]
    user = FactoryBot.create(:saml_user)
    sign_in user
    user
  end

  def login_system_admin_registered_user
    @request.env["devise.mapping"] = Devise.mappings[:registered_user]
    user = FactoryBot.create(:system_admin_registered_user)
    sign_in user
    user
  end

  def login_registered_user
    @request.env["devise.mapping"] = Devise.mappings[:registered_user]
    user = FactoryBot.create(:registered_user)
    sign_in user
    user
  end

  def login_as_user(user)
    case @user.type
    when 'SamlUser'
      @request.env["devise.mapping"] = Devise.mappings[:saml_user]
    when 'RegisteredUser'
      @request.env["devise.mapping"] = Devise.mappings[:registered_user]
    else
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end
    sign_in user
  end
end
