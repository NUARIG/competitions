namespace :grants do
  desc 'Load or update initial Grants'
  task(load: :environment) do
    Competitions::Setup.load_grants
  end
end
