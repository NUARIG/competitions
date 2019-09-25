# frozen_string_literal: true

module Competitions
  module Setup
    def self.all
      Competitions::Setup::Users.load_users
    end

    module_function

    def parse_yml_file(filename)
      HashWithIndifferentAccess
        .new(YAML.load_file("./lib/competitions/data/#{filename}.yml"))
    end

    module Users
      def self.load_users
        users = Competitions::Setup.parse_yml_file('users')
        users.each do |_, data|
          user = User
                 .where(upn: data[:upn])
                 .first_or_initialize

          user.first_name         = data[:first_name]
          user.last_name          = data[:last_name]
          user.email              = data[:email]
          user.upn                = data[:upn]
          user.system_admin       = data[:system_admin]
          user.era_commons        = data[:era_commons]
          user.grant_creator      = data[:grant_creator]

          user.save!
        end
      end
    end
  end
end
