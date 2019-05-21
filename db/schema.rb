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

ActiveRecord::Schema.define(version: 2019_05_10_194117) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "grant_forms", force: :cascade do |t|
    t.bigint "grant_id", null: false
    t.bigint "grant_submission_form_id", null: false
    t.integer "display_order"
    t.boolean "disabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order", "grant_id"], name: "index_grant_forms_on_display_order_and_grant_id", unique: true
    t.index ["grant_id"], name: "index_grant_forms_on_grant_id"
    t.index ["grant_submission_form_id", "grant_id"], name: "index_grant_forms_on_grant_submission_form_id_and_grant_id", unique: true
    t.index ["grant_submission_form_id"], name: "index_grant_forms_on_grant_submission_form_id"
  end

  create_table "grant_permissions", force: :cascade do |t|
    t.bigint "grant_id"
    t.bigint "user_id"
    t.string "role"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_id"], name: "index_grant_permissions_on_grant_id"
    t.index ["user_id"], name: "index_grant_permissions_on_user_id"
  end

  create_table "grant_submission_forms", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", limit: 3000
    t.bigint "created_id"
    t.bigint "updated_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_grant_submission_forms_on_title", unique: true
  end

  create_table "grant_submission_multiple_choice_options", force: :cascade do |t|
    t.bigint "grant_submission_question_id", null: false
    t.string "text", null: false
    t.integer "display_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order", "grant_submission_question_id"], name: "i_smco_on_display_order_and_submission_question_id", unique: true
    t.index ["grant_submission_question_id"], name: "i_gsmco_on_submission_question_id"
    t.index ["text", "grant_submission_question_id"], name: "i_smco_on_text_and_submission_question_id", unique: true
  end

  create_table "grant_submission_questions", force: :cascade do |t|
    t.bigint "grant_submission_section_id", null: false
    t.string "text", limit: 4000, null: false
    t.string "instruction", limit: 4000
    t.integer "display_order", null: false
    t.string "export_code"
    t.boolean "is_mandatory"
    t.string "response_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order", "grant_submission_section_id"], name: "i_sqs_on_display_order_and_submission_section_id", unique: true
    t.index ["grant_submission_section_id"], name: "index_grant_submission_questions_on_grant_submission_section_id"
    t.index ["text", "grant_submission_section_id"], name: "i_gsq_on_text_and_grant_submission_section_id", unique: true
  end

  create_table "grant_submission_responses", force: :cascade do |t|
    t.bigint "grant_submission_submission_id", null: false
    t.bigint "grant_submission_question_id", null: false
    t.bigint "grant_submission_multiple_choice_option_id"
    t.string "string_val"
    t.text "text_val"
    t.decimal "decimal_val"
    t.datetime "datetime_val"
    t.boolean "boolean_val"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_submission_multiple_choice_option_id"], name: "i_gsr_on_submission_multiple_choice_option_id"
    t.index ["grant_submission_question_id", "grant_submission_submission_id"], name: "i_gsr_on_submissisubmission_id", unique: true
    t.index ["grant_submission_question_id"], name: "i_gsr_on_grant_submission_question_id"
    t.index ["grant_submission_submission_id"], name: "i_gsr_on_grant_submission_submission_id"
  end

  create_table "grant_submission_sections", force: :cascade do |t|
    t.bigint "grant_submission_form_id", null: false
    t.string "title"
    t.integer "display_order", null: false
    t.boolean "repeatable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order", "grant_submission_form_id"], name: "i_submission_sections_on_display_order_and_submission_form_id", unique: true
    t.index ["grant_submission_form_id"], name: "index_grant_submission_sections_on_grant_submission_form_id"
  end

  create_table "grant_submission_submissions", force: :cascade do |t|
    t.bigint "grant_id", null: false
    t.bigint "grant_submission_form_id", null: false
    t.bigint "created_id", null: false
    t.string "title", null: false
    t.bigint "grant_submission_section_id"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_id", "grant_submission_form_id"], name: "i_gss_on_created_id_and_submission_form_id"
    t.index ["grant_id", "created_id"], name: "i_gss_on_grant_id_and_created_id"
    t.index ["grant_id"], name: "index_grant_submission_submissions_on_grant_id"
    t.index ["grant_submission_form_id"], name: "index_grant_submission_submissions_on_grant_submission_form_id"
  end

  create_table "grant_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", null: false
    t.index ["item_type", "item_id"], name: "index_grant_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "index_grant_versions_on_whodunnit"
  end

  create_table "grants", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "state", null: false
    t.date "publish_date", null: false
    t.date "submission_open_date", null: false
    t.date "submission_close_date", null: false
    t.text "rfa"
    t.integer "applications_per_user"
    t.text "review_guidance"
    t.integer "max_reviewers_per_proposal"
    t.integer "max_proposals_per_reviewer"
    t.date "review_open_date"
    t.date "review_close_date"
    t.date "panel_date"
    t.text "panel_location"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_grants_on_organization_id"
    t.index ["slug"], name: "index_grants_on_slug"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "organization_role"
    t.string "email", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "era_commons"
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

  add_foreign_key "grant_permissions", "grants"
  add_foreign_key "grant_permissions", "users"
  add_foreign_key "grant_submission_questions", "grant_submission_sections"
  add_foreign_key "grants", "organizations"
  add_foreign_key "users", "organizations"
end
