module Competitions
  module Setup
    def self.all
      Competitions::Setup.load_constraints
      Competitions::Setup.load_fields
      Competitions::Setup.load_constraint_fields
      Competitions::Setup.load_organizations
      Competitions::Setup.load_users
      Competitions::Setup.load_grants
    end

    def self.load_constraints
      constraints = HashWithIndifferentAccess.new(YAML.load_file('./lib/competitions/data/constraints.yml'))
      constraints.each do |_, data|
        constraint            = Constraint
                                  .where(type: data[:type], name: data[:name])
                                  .first_or_initialize
        constraint.name       = data[:name]
        constraint.type       = data[:type]
        constraint.value_type = data[:value_type]
        constraint.default    = data[:default]
        constraint.save!
      end
    end

    def self.load_fields
      fields = HashWithIndifferentAccess.new(YAML.load_file('./lib/competitions/data/fields.yml'))
      fields.each do |_, data|
        field             = Field
                              .where(label: data[:label])
                              .first_or_initialize
        field.type        = data[:type]
        field.label       = data[:label]
        field.help_text   = data[:help_text] if data[:help_text].present?
        field.placeholder = data[:placeholder] if data[:placeholder].present?
        field.save!
      end
    end

    def self.load_constraint_fields
      constraint_fields = HashWithIndifferentAccess.new(YAML.load_file('./lib/competitions/data/constraint_fields.yml'))
      constraint_fields.each do |_, data|
        constraint_field              = ConstraintField
                                          .where(field_id: data[:field_id], constraint_id: data[:constraint_id])
                                          .first_or_initialize
        constraint_field.field_id      = data[:field_id]
        constraint_field.constraint_id = data[:constraint_id]
        constraint_field.value         = data[:value] if data[:value].present?
        constraint_field.save!
      end
    end

    def self.load_users
      users = HashWithIndifferentAccess.new(YAML.load_file('./lib/competitions/data/users.yml'))
      users.each do |_, data|
        user                 = User
                                 .where(email: data[:email])
                                 .first_or_initialize
        user.organization_id = data[:organization_id]
        user.first_name      = data[:first_name]
        user.last_name       = data[:last_name]
        user.email           = data[:email]
        user.save!
      end
    end

    def self.load_organizations
      organizations = HashWithIndifferentAccess.new(YAML.load_file('./lib/competitions/data/organizations.yml'))
      organizations.each do |_, data|
        organization            = Organization
                                    .where(name: data[:name])
                                    .first_or_initialize
        organization.name       = data[:name]
        organization.short_name = data[:short_name]
        organization.url        = data[:url]
        organization.save!
      end
    end

    def self.load_grants
      grants = HashWithIndifferentAccess.new(YAML.load_file('./lib/competitions/data/grants.yml'))
      grants.each do |_, data|
        byebug
        grant                            = Grant
                                             .where(name: data[:name])
                                             .first_or_initialize
        grant.organization_id            = data[:organization_id]
        grant.user_id                    = data[:user_id]
        grant.name                       = data[:name]
        grant.short_name                 = data[:short_name]
        grant.state                      = data[:state]
        grant.initiation_date            = data[:initiation_date]
        grant.submission_open_date       = data[:submission_open_date]
        grant.submission_close_date      = data[:submission_close_date]
        grant.rfa                        = data[:rfa]
        grant.min_budget                 = data[:min_budget]
        grant.max_budget                 = data[:max_budget]
        grant.applications_per_user      = data[:applications_per_user]
        grant.review_guidance            = data[:review_guidance]
        grant.max_reviewers_per_proposal = data[:max_reviewers_per_proposal]
        grant.max_proposals_per_reviewer = data[:max_proposals_per_reviewer]
        grant.panel_date                 = data[:panel_date]
        grant.panel_location             = data[:panel_location]
        byebug
        grant.save!
      end
    end
  end
end
