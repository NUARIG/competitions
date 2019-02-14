namespace :constraint_questions do
  desc 'Load or update initial ConstraintQuestions'
  task(load: :environment) do
    Competitions::Setup.load_constraint_questions
  end
end
