module DeviseSamlAuthenticatable
  class CompetitionsAttributeMapResolver < DeviseSamlAuthenticatable::DefaultAttributeMapResolver
    def attribute_map
      COMPETITIONS_CONFIG[:saml][:attribute_map]
    end
  end
end