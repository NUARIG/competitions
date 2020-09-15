module DeviseSamlAuthenticatable
  class CompetitionsAttributeMapResolver < DeviseSamlAuthenticatable::DefaultAttributeMapResolver
    def attribute_map
      COMPETITIONS_CONFIG[:devise][:saml_authenticatable][:attribute_map]
    end
  end
end
