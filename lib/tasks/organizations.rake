namespace :organizations do
  desc 'Load or update initial Oraganizations'
  task(load: :environment) do
    Competitions::Setup.load_organizations
  end
end
