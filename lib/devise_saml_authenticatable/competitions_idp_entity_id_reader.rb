module DeviseSamlAuthenticatable
  class CompetitionsIdpEntityIdReader
    def self.entity_id(params)
      if params[:SAMLRequest]
        Rails.logger.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        Rails.logger.info("I am in the first if")
        OneLogin::RubySaml::SloLogoutrequest.new(
          params[:SAMLRequest],
          settings: Devise.saml_config,
          allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
        ).issuer
      elsif params[:SAMLResponse]
        Rails.logger.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        Rails.logger.info("I am in the first elsif")
        # r = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
        # Rails.logger.info("Message: #{r.document.inspect}~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        # if REXML::XPath.match(r, "/p:LogoutResponse/a:Issuer", { "p" => PROTOCOL, "a" => ASSERTION }).any?
        #   OneLogin::RubySaml::SloLogoutresponse.new(
        #     params[:SAMLRequest],
        #     settings: Devise.saml_config,
        #     allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
        #   ).issuer
        # else
        #   OneLogin::RubySaml::Response.new(
        #     params[:SAMLResponse],
        #     settings: Devise.saml_config,
        #     allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
        #   ).issuers.first
        # end
        begin
          Rails.logger.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~")
          Rails.logger.info("I am in the first begin")
          OneLogin::RubySaml::Response.new(
            params[:SAMLResponse],
            settings: Devise.saml_config,
            allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
          ).issuers.first
        rescue
          Rails.logger.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~")
          Rails.logger.info("I am in the first rescue")
          OneLogin::RubySaml::SloLogoutresponse.new(
            params[:SAMLRequest],
            settings: Devise.saml_config,
            allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
          ).issuer
        end
      end
    end
  end
end

# module DeviseSamlAuthenticatable
#   class CompetitionsIdpEntityIdReader
#     def self.entity_id(params)
#       if params[:SAMLRequest]
#         OneLogin::RubySaml::SloLogoutrequest.new(
#           params[:SAMLRequest],
#           settings: Devise.saml_config,
#           allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
#         ).issuer
#       elsif params[:SAMLResponse]
#         OneLogin::RubySaml::Response.new(
#           params[:SAMLResponse],
#           settings: Devise.saml_config,
#           allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
#         ).issuers.first
#       end
#     end
#   end
# end