FactoryBot.define do
  factory :panel do
    association       :grant, factory: :grant
    start_datetime    { grant.submission_close_date + 1.day }
    end_datetime      { grant.submission_close_date + 2.days }
    instructions      { Faker::Lorem.paragraph }
    meeting_link      { Faker::Internet.url(host: 'zoom-teams.io')}
    meeting_location  { Faker::Address.full_address }
  end
end
