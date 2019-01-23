module Competitions
  module Setup
    def self.all
      Competitions::Setup.load_constraints
      Competitions::Setup.load_fields
    end

    def self.load_constraints
      constraints = HashWithIndifferentAccess.new(YAML.load_file('./lib/competitions/data/constraints.yml'))
      constraints.each do |_, data|
        constraint            = Constraint
                                  .where(field_type: data[:field_type], name: data[:name])
                                  .first_or_initialize
        constraint.name       = data[:name]
        constraint.field_type = data[:field_type]
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
        field.label       = data[:label]
        field.help_text   = data[:help_text] if data[:help_text].present?
        field.placeholder = data[:placeholder] if data[:placeholder].present?
        field.save!

        # add_constraints(field, data)
      end
    end
  end
end
