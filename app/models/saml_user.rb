class SamlUser < User

  # devise :saml_authenticatable, :trackable, :timeoutable
  devise :saml_authenticatable

end
