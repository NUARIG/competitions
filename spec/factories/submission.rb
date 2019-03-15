FactoryBot.define do
  factory :draft_submission, class: 'Submission' do
    association :grant,         factory: :grant
    association :user,          factory: :user
    project_title               { Faker::Lorem.sentence }
    state                       { 'draft' }
    composite_score_average     nil
    final_impact_score_average  nil
    award_amount                nil
  end

  factory :complete_submission, class: 'Submission' do
    association :grant,         factory: :grant
    association :user,          factory: :user
    project_title               { Faker::Lorem.sentence }
    state                       { 'complete' }
    composite_score_average     nil
    final_impact_score_average  nil
    award_amount                nil
  end

  factory :complete_scored_submission, class: 'Submission' do
    association :grant,         factory: :grant
    association :user,          factory: :user
    project_title               { Faker::Lorem.sentence }
    state                       { 'complete' }
    composite_score_average     { 2 }
    final_impact_score_average  { 2 }
    award_amount                nil
  end

  factory :awarded_submission, class: 'Submission' do
    association :grant,         factory: :grant
    association :user,          factory: :user
    project_title               { Faker::Lorem.sentence }
    state                       { 'complete' }
    composite_score_average     { 2 }
    final_impact_score_average  { 2 }
    award_amount                { 99.99}
  end
end
