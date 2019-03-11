# frozen_string_literal: true

namespace :constraints do
  desc 'Load or update initial Constraints'
  task(load: :environment) do
    Competitions::Setup.load_constraints
  end
end
