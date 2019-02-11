FactoryBot.define do
  factory :string_field, class: Field do
    label       { 'String Field Name' }
    type        { 'StringField' }
    help_text   { 'Lorem ipsum, dolor sum.' }
    placeholder { 'Lorem ipsum' }
  end

  factory :integer_field, class: Field do
    label       { 'Integer Field Name' }
    type        { 'IntegerField' }
    help_text   { 'Lorem ipsum, dolor sum.' }
    placeholder { 'Lorem ipsum' }
  end

  factory :float_field, class: Field do
    label       { 'Float Field Name' }
    type        { 'FloatField' }
    help_text   { 'Lorem ipsum, dolor sum.' }
    placeholder { 'Lorem ipsum' }
  end
end
