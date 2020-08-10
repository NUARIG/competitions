class SamlUser < User
  attr_accessor Devise.saml_session_index_key.to_sym
  devise :saml_authenticatable

  # https://github.com/apokalipto/devise_saml_authenticatable/issues/151
  def authenticatable_salt
    self.read_attribute(Devise.saml_session_index_key.to_sym) if self.read_attribute(Devise.saml_session_index_key.to_sym).present?
  end
end
