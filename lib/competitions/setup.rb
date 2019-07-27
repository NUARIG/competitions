# frozen_string_literal: true

module Competitions
  module Setup
    def self.all
      Competitions::Setup::Users.load_users
      Competitions::Setup::Grants.load_grants
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
          user.organization_role  = data[:organization_role]
          user.era_commons        = data[:era_commons]

          user.save!
        end
      end
    end

    module Grants
      def self.load_grants
        org_admin_user = User.where(organization_role: 'admin').first

        grants = Competitions::Setup.parse_yml_file('grants')
        grants.each do |_, data|
          grant = Grant
                  .where(name: data[:name])
                  .first_or_initialize

          grant.name                       = data[:name]
          grant.slug                       = data[:slug]
          grant.state                      = data[:state]
          grant.publish_date               = data[:publish_date]
          grant.submission_open_date       = data[:submission_open_date]
          grant.submission_close_date      = data[:submission_close_date]
          grant.rfa                        = data[:rfa]
          grant.applications_per_user      = data[:applications_per_user]
          grant.review_guidance            = data[:review_guidance]
          grant.max_reviewers_per_proposal = data[:max_reviewers_per_proposal]
          grant.max_proposals_per_reviewer = data[:max_proposals_per_reviewer]
          grant.review_open_date           = data[:review_open_date]
          grant.review_close_date          = data[:review_close_date]
          grant.panel_date                 = data[:panel_date]
          grant.panel_location             = data[:panel_location]

          grant.save!
          grant.versions.last.update_attribute(:whodunnit, org_admin_user.id)

          unless data[:grant_permissions].nil?
            load_grant_permissions(data[:grant_permissions], grant.id)
          end
        end
      end

      def self.load_grant_permissions(grant_permissions, grant_id)
        grant_permissions.each do |_, gu|
          grant_permission = GrantPermission
                       .where(grant_id: grant_id, user_id: gu[:user_id])
                       .first_or_initialize

          grant_permission.role = gu[:role]
          grant_permission.save!
        end
      end

    end

  end
end
