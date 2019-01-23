FactoryBot.define do
  factory :field do
    label       { 'Field Name' }
    type        { 'IntegerField' }
    help_text   { 'Lorem ipsum, dolor sum.' }
    placeholder { 'Lorem ipsum' }
  end
end
