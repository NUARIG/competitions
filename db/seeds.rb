# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

Competitions::Setup::Organizations.load_organizations
Competitions::Setup::Users.load_users
Competitions::Setup::Constraints.load_constraints
Competitions::Setup::Grants.load_grants
Competitions::Setup::DefaultSets.load_default_sets
