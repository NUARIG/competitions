class SamlUser < User

  devise :saml_authenticatable, :trackable, :timeoutable

end
