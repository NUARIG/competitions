class SamlSessionsController < Devise::SamlSessionsController
  after_action :do_something, only: :create

  # # def new
  # #   super
  # #   # puts "NEW: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  # #   # # super from DEVISE_SAML_AUTHENTICATABLE
  # #   # idp_entity_id = get_idp_entity_id(params)
  # #   # request = OneLogin::RubySaml::Authrequest.new
  # #   # auth_params = { RelayState: relay_state } if relay_state
  # #   # action = request.create(saml_config(idp_entity_id), auth_params || {})
  # #   # redirect_to action
  # # end

  # def create
  #   puts "CREATE: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #   # current_user.session_index = ''
  #   # super from DEVISE
  #   # current_user.session_index = ''
  #   self.resource = warden.authenticate!(auth_options)
  #   byebug
  #   set_flash_message!(:notice, :signed_in)
  #   sign_in(resource_name, resource)
  #   yield resource if block_given?
  #   respond_with resource, location: after_sign_in_path_for(resource)

  #   # current_user.session_index = session["warden.user.user.key"].last

  #   puts "CURRENT_USER: #{current_user.inspect}"
  #   puts "CURRENT_USER: #{current_user.session_index}"
  #   puts "CREATE END: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  # end

  # # # def destroy
  # # #   super
  # # # end

  # private

  def do_something
    # current_user.session_index = session["warden.user.user.key"].last
    # byebug
    puts "do_something:  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    cookies[:session_index] = {
       :value => session["warden.user.user.key"].last,
       :expires => 8.hour.from_now,
       :domain => Rails.application.credentials.dig(Rails.env.to_sym, :app_domain)
     }

     puts cookies[:session_index]
     # cookies.delete(:key, :domain => 'domain.com')
     puts "do_something:  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  end
end
