# frozen_string_literal: true

module Competitions
  module Setup
    def self.all
      Competitions::Setup::Organizations.load_organizations
      Competitions::Setup::Users.load_users
      Competitions::Setup::Constraints.load_constraints
      Competitions::Setup::DefaultSets.load_default_sets
      Competitions::Setup::Grants.load_grants
    end

    module_function

    def parse_yml_file(filename)
      HashWithIndifferentAccess
        .new(YAML.load_file("./lib/competitions/data/#{filename}.yml"))
    end

    module Constraints
      def self.load_constraints
        constraints = Competitions::Setup.parse_yml_file('constraints')
        constraints.each do |_, data|
          constraint = Constraint
                       .where(type: data[:type], name: data[:name])
                       .first_or_initialize

          constraint.name       = data[:name]
          constraint.type       = data[:type]
          constraint.value_type = data[:value_type]
          constraint.default    = data[:default]
          constraint.save!
        end
      end
    end

    module Users
      def self.load_users
        users = Competitions::Setup.parse_yml_file('users')
        users.each do |_, data|
          user = User
                 .where(email: data[:email])
                 .first_or_initialize

          user.organization_id    = data[:organization_id]
          user.first_name         = data[:first_name]
          user.last_name          = data[:last_name]
          user.email              = data[:email]
          user.organization_role  = data[:organization_role]
          user.password           = data[:password]
          user.era_commons        = data[:era_commons]

          user.save!
        end
      end
    end

    module Organizations
      def self.load_organizations
        organizations = Competitions::Setup.parse_yml_file('organizations')
        organizations.each do |_, data|
          organization = Organization
                         .where(name: data[:name])
                         .first_or_initialize

          organization.name       = data[:name]
          organization.short_name = data[:short_name]
          organization.url        = data[:url]
          organization.save!
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

          grant.organization_id            = data[:organization_id]
          grant.name                       = data[:name]
          grant.short_name                 = data[:short_name]
          grant.state                      = data[:state]
          grant.initiation_date            = data[:initiation_date]
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

          byebug
          grant.save!
          grant.versions.last.update_attribute(:whodunnit, org_admin_user.id)

          unless data[:grant_users].nil?
            load_grant_users(data[:grant_users], grant.id)
          end
        end
      end

      def self.load_grant_users(grant_users, grant_id)
        grant_users.each do |_, gu|
          grant_user = GrantUser
                       .where(grant_id: grant_id, user_id: gu[:user_id])
                       .first_or_initialize

          grant_user.grant_role = gu[:grant_role]
          grant_user.save!
        end
      end
    end

    module DefaultSets
      def self.load_default_sets
        default_sets = Competitions::Setup.parse_yml_file('default_sets')
        default_sets.each do |_, data|
          set = DefaultSet.where(name: data[:name]).first_or_initialize
          set.name = data[:name]
          set.save!

          next unless data[:questions].any?

          data[:questions].each do |_, q|
            DefaultSetQuestion
              .find_or_create_by(default_set_id: set.id,
                                 question_id: load_question(q).id)
          end
        end
      end

      def self.load_question(q)
        question = Question
                   .where(grant_id: q[:grant_id], name: q[:name])
                   .first_or_initialize
        question.name             = q[:name]
        question.answer_type      = q[:answer_type]
        question.help_text        = q[:help_text]
        question.placeholder_text = q[:placeholder_text]
        question.required         = q[:required]
        question.save!

        if q[:constraints].any?
          q[:constraints].each do |_, constraint|
            load_constraint_questions(question.id, constraint)
          end
        end

        question
      end

      def self.load_constraint_questions(question_id, constraint)
        constraint_id       = Constraint
                              .where(type: constraint[:type],
                                     name: constraint[:name])
                              .pluck(:id)
                              .first
        constraint_question = ConstraintQuestion
                              .where(constraint_id: constraint_id,
                                     question_id: question_id)
                              .first_or_initialize

        constraint_question.value = constraint[:value]
        constraint_question.save!
      end
    end
  end
end
