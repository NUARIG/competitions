RSpec.configure do |config|
  def random_user
    [:saml_user, :registered_user].sample
  end

  def random_system_admin_user
    [:system_admin_saml_user, :system_admin_registered_user].sample
  end

  def random_grant_creator_user
    [:grant_creator_saml_user, :grant_creator_registered_user].sample
  end

  def login_user(user)
    login_as(user, scope: user.type.underscore.to_sym)
  end
end
