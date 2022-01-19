module Devise
  class CompetitionsFailureApp < Devise::FailureApp
    protected

    def i18n_message(default = nil)
      domain          = params[:registered_user][:uid].split("@").last
      saml_domains    = COMPETITIONS_CONFIG[:devise][:registerable][:saml_domains]
      idp_entity_name = COMPETITIONS_CONFIG[:devise][:saml_authenticatable][:idp_entity_name]


      message = warden_message || default || :unauthenticated

      message = :idp_entity_message if (message == :not_found_in_database && saml_domains.include?(domain))

      if message.is_a?(Symbol)
        options = {}
        options[:resource_name] = scope
        options[:scope] = "devise.failure"
        options[:default] = [message]
        auth_keys = scope_class.authentication_keys
        keys = (auth_keys.respond_to?(:keys) ? auth_keys.keys : auth_keys).map { |key| scope_class.human_attribute_name(key) }
        options[:authentication_keys] = keys.join(I18n.translate(:"support.array.words_connector"))
        options = i18n_options(options)

        I18n.t(:"#{scope}.#{message}", **options)
      else
        message.to_s
      end
    end
  end
end