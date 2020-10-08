FactoryBot.define do
  factory :panel do
    association       :grant, factory: :grant
    start_datetime    { grant.submission_close_date + 1.day }
    end_datetime      { grant.submission_close_date + 2.days }
    instructions      { Faker::Lorem.paragraph }
    meeting_link      { Faker::Internet.url(host: 'zoom-teams.io', scheme: 'https')}
    meeting_location  { Faker::Address.full_address }

    trait :open do
      association       :grant, factory: :published_closed_grant_with_users
      start_datetime    { 1.hour.ago      }
      end_datetime      { 1.hour.from_now }
    end

    trait :before_start_datetime do
      association       :grant, factory: :published_closed_grant_with_users
      start_datetime    { 1.hour.from_now   }
      end_datetime      { 2.hours.from_now  }
    end

    trait :after_end_datetime do
      association       :grant, factory: :published_closed_grant_with_users
      start_datetime    { 2.hours.ago }
      end_datetime      { 1.hour.ago  }
    end

    trait :no_panel_dates do
      start_datetime    { nil }
      end_datetime      { nil }
    end

    factory :open_panel,      traits: %i[open]
    factory :closed_panel,    traits: %i[before_start_datetime]
    factory :before_panel,    traits: %i[before_start_datetime]
    factory :after_panel,     traits: %i[after_end_datetime]
    factory :no_panel_dates,  traits: %i[no_panel_dates]
  end
end
