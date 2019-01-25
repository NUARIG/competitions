module Competitions
  module Setup
    def self.all
      Competitions::Setup.load_constraints
      Competitions::Setup.load_fields
      Competitions::Setup.load_constraint_fields
      Competitions::Setup.load_organizations
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
        byebug
        constraint_field              = ConstraintField
                                          .where(field_id: data[:field_id], constraint_id: data[:constraint_id])
                                          .first_or_initialize
        constraint_field.field_id      = data[:field_id]
        constraint_field.constraint_id = data[:constraint_id]
        constraint_field.value         = data[:value] if data[:value].present?
        constraint_field.save!
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
        grant                 = Grant
                                .where(name: data[:name])
                                .first_or_initialize
        grant.organization_id = data[:organization_id]
        grant.name            = data[:name]
        grant.short_name      = data[:short_name]
        grant.save!
      end
    end
  end
end
