namespace :fields do
  desc 'Load or update initial Fields'
  task(load: :environment) do
    Competitions::Setup.load_fields
  end
end
