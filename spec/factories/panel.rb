FactoryBot.define do
  factory :panel do
    association       :grant, factory: :grant
    start_datetime    { 1.day.from_now }
    end_datetime      { 2.days.from_now }
    instructions      { Faker::Lorem.paragraph }
    meeting_link      { Faker::Internet.url(host: 'zoom-teams.com')}
    meeting_location  { Faker::Address.full_address }
  end
end
