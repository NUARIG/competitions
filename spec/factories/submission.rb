FactoryBot.define do
  factory :submission, aliases: %i[draft_submission draft_submission_with_complete_open_grant] do
    association :grant,         factory: :complete_open_grant
    association :user,          factory: :user
    project_title               { Faker::Lorem.sentence }
    state                       { 'draft' }

    trait :submitted do
      state { 'submitted' }
    end

    trait :with_complete_closed_grant do
      association :grant, factory: :complete_closed_grant
    end

    trait :scored do
      composite_score_average     { 2 }
      final_impact_score_average  { 2 }
    end

    trait :awarded do
      award_amount { 99.99 }
    end

    factory :wubmitted_submission,                              traits: %i[submitted]
    factory :submitted_scored_submission,                       traits: %i[submitted scored]
    factory :submitted_awarded_submission,                      traits: %i[submitted scored awarded]
    factory :submission_with_complete_closed_grant,             traits: %i[with_complete_closed_grant]
    factory :submitted_submission_with_complete_closed_grant,  traits: %i[submitted with_complete_closed_grant]
  end
end