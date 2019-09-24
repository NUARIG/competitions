module DeviseSamlAuthenticatable
  class CompetitionsIdpEntityIdReader
    def self.entity_id(params)
      if params[:SAMLRequest]
        OneLogin::RubySaml::SloLogoutrequest.new(
          params[:SAMLRequest],
          settings: Devise.saml_config,
          allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
        ).issuer
      elsif params[:SAMLResponse]
        response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
        if response.destination == Rails.application.credentials.dig(Rails.env.to_sym, :una_assertion_consumer_service_url)
        # response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
          OneLogin::RubySaml::Response.new(
            params[:SAMLResponse],
            settings: Devise.saml_config,
            allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
          ).issuers.first
        else
          OneLogin::RubySaml::Logoutrequest.new(params[:SAMLResponse]).issuer
        end
      end
    end
  end
end
