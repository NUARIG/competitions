module Devise
  class CompetitionsFailureApp < Devise::FailureApp
    protected

    def i18n_message(default = nil)

      message = warden_message || default || :unauthenticated

      if params[:registered_user].present?
        user_domain     = params[:registered_user][:uid].split("@").last
        saml_domains    = COMPETITIONS_CONFIG[:devise][:registerable][:saml_domains]
        idp_entity_name = COMPETITIONS_CONFIG[:devise][:saml_authenticatable][:idp_entity_name]

        if (message == :not_found_in_database && saml_domains.include?(user_domain))
          message   = :saml_user_domain
        end
      end

      if message.is_a?(Symbol)
        options = {}
        options[:resource_name] = scope
        options[:scope] = "devise.failure"
        options[:default] = [message]
        auth_keys = scope_class.authentication_keys
        keys = (auth_keys.respond_to?(:keys) ? auth_keys.keys : auth_keys).map { |key| scope_class.human_attribute_name(key) }
        options[:authentication_keys] = keys.join(I18n.translate(:"support.array.words_connector"))
        options = i18n_options(options)

        options[:link]      = Rails.application.routes.url_helpers.new_saml_user_session_path
        options[:link_text] = "Log in with your #{COMPETITIONS_CONFIG[:devise][:saml_authenticatable][:idp_entity_name]}."

        I18n.t(:"#{scope}.#{message}", **options)
      else
        message.to_s
      end
    end
  end
end