namespace :constraint_fields do
  desc 'Load or update initial ConstraintFields'
  task(load: :environment) do
    Competitions::Setup.load_constraint_fields
  end
end
