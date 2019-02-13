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

ActiveRecord::Schema.define(version: 2019_02_11_162144) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "constraint_questions", force: :cascade do |t|
    t.bigint "constraint_id"
    t.bigint "question_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["constraint_id", "question_id"], name: "index_constraint_questions_on_constraint_id_and_question_id"
    t.index ["constraint_id"], name: "index_constraint_questions_on_constraint_id"
    t.index ["question_id"], name: "index_constraint_questions_on_question_id"
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
    t.date "review_open_date"
    t.date "review_close_date"
    t.date "panel_date"
    t.text "panel_location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_grants_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "field_id"
    t.bigint "grant_id"
    t.text "name"
    t.text "help_text"
    t.text "placeholder_text"
    t.boolean "required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id", "grant_id"], name: "index_questions_on_field_id_and_grant_id"
    t.index ["field_id"], name: "index_questions_on_field_id"
    t.index ["grant_id"], name: "index_questions_on_grant_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "organization_role"
    t.string "email", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "grants", "organizations"
  add_foreign_key "users", "organizations"
end
