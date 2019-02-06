# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_21_175254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "constraint_fields", force: :cascade do |t|
    t.bigint "constraint_id"
    t.bigint "field_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["constraint_id", "field_id"], name: "index_constraint_fields_on_constraint_id_and_field_id"
    t.index ["constraint_id"], name: "index_constraint_fields_on_constraint_id"
    t.index ["field_id"], name: "index_constraint_fields_on_field_id"
  end

  create_table "constraints", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "value_type"
    t.string "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["value_type"], name: "index_constraints_on_value_type"
  end

  create_table "fields", force: :cascade do |t|
    t.string "type"
    t.string "label"
    t.string "help_text"
    t.string "placeholder"
    t.boolean "require"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grants", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "user_id"
    t.string "name"
    t.string "short_name"
    t.string "state"
    t.date "initiation_date"
    t.date "submission_open_date"
    t.date "submission_close_date"
    t.text "rfa"
    t.float "min_budget"
    t.float "max_budget"
    t.integer "applications_per_user"
    t.text "review_guidance"
    t.integer "max_reviewers_per_proposal"
    t.integer "max_proposals_per_reviewer"
    t.date "panel_date"
    t.text "panel_location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_grants_on_organization_id"
    t.index ["user_id"], name: "index_grants_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "organization_role"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "grants", "organizations"
  add_foreign_key "grants", "users"
  add_foreign_key "users", "organizations"
end
