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

ActiveRecord::Schema.define(version: 2019_02_25_161519) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
  add_foreign_key "grants", "organizations"
  add_foreign_key "users", "organizations"
end
