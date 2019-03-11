# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_190_305_222_413) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'constraint_question_versions', force: :cascade do |t|
    t.string 'item_type', null: false
    t.integer 'item_id', null: false
    t.string 'event', null: false
    t.integer 'whodunnit'
    t.text 'object'
    t.datetime 'created_at', null: false
    t.index %w[item_type item_id], name: 'index_constraint_question_versions_on_item_type_and_item_id'
    t.index ['whodunnit'], name: 'index_constraint_question_versions_on_whodunnit'
  end

  create_table 'constraint_questions', force: :cascade do |t|
    t.bigint 'constraint_id'
    t.bigint 'question_id'
    t.string 'value'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[constraint_id question_id], name: 'index_constraint_questions_on_constraint_id_and_question_id'
    t.index ['constraint_id'], name: 'index_constraint_questions_on_constraint_id'
    t.index ['question_id'], name: 'index_constraint_questions_on_question_id'
  end

  create_table 'constraints', force: :cascade do |t|
    t.string 'type'
    t.string 'name'
    t.string 'value_type'
    t.string 'default'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['value_type'], name: 'index_constraints_on_value_type'
  end

  create_table 'default_set_questions', force: :cascade do |t|
    t.bigint 'default_set_id'
    t.bigint 'question_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[default_set_id question_id], name: 'index_default_set_questions_on_default_set_id_and_question_id'
    t.index ['default_set_id'], name: 'index_default_set_questions_on_default_set_id'
    t.index ['question_id'], name: 'index_default_set_questions_on_question_id'
  end

  create_table 'default_sets', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'grant_users', force: :cascade do |t|
    t.bigint 'grant_id'
    t.bigint 'user_id'
    t.string 'grant_role'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['grant_id'], name: 'index_grant_users_on_grant_id'
    t.index ['user_id'], name: 'index_grant_users_on_user_id'
  end

  create_table 'grant_versions', force: :cascade do |t|
    t.string 'item_type', null: false
    t.integer 'item_id', null: false
    t.string 'event', null: false
    t.integer 'whodunnit'
    t.text 'object'
    t.datetime 'created_at', null: false
    t.index %w[item_type item_id], name: 'index_grant_versions_on_item_type_and_item_id'
    t.index ['whodunnit'], name: 'index_grant_versions_on_whodunnit'
  end

  create_table 'grants', force: :cascade do |t|
    t.bigint 'organization_id'
    t.string 'name'
    t.string 'short_name'
    t.string 'state'
    t.date 'initiation_date'
    t.date 'submission_open_date'
    t.date 'submission_close_date'
    t.text 'rfa'
    t.float 'min_budget'
    t.float 'max_budget'
    t.integer 'applications_per_user'
    t.text 'review_guidance'
    t.integer 'max_reviewers_per_proposal'
    t.integer 'max_proposals_per_reviewer'
    t.date 'review_open_date'
    t.date 'review_close_date'
    t.date 'panel_date'
    t.text 'panel_location'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['organization_id'], name: 'index_grants_on_organization_id'
  end

  create_table 'organizations', force: :cascade do |t|
    t.string 'name'
    t.string 'short_name'
    t.string 'url'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'question_versions', force: :cascade do |t|
    t.string 'item_type', null: false
    t.integer 'item_id', null: false
    t.string 'event', null: false
    t.integer 'whodunnit'
    t.text 'object'
    t.datetime 'created_at', null: false
    t.index %w[item_type item_id], name: 'index_question_versions_on_item_type_and_item_id'
    t.index ['whodunnit'], name: 'index_question_versions_on_whodunnit'
  end

  create_table 'questions', force: :cascade do |t|
    t.bigint 'grant_id'
    t.text 'answer_type'
    t.text 'name'
    t.text 'help_text'
    t.text 'placeholder_text'
    t.boolean 'required'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['grant_id'], name: 'index_questions_on_grant_id'
  end

  create_table 'users', force: :cascade do |t|
    t.bigint 'organization_id'
    t.string 'organization_role'
    t.string 'email', default: '', null: false
    t.string 'first_name'
    t.string 'last_name'
    t.string 'era_commons'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['organization_id'], name: 'index_users_on_organization_id'
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  add_foreign_key 'grant_users', 'grants'
  add_foreign_key 'grant_users', 'users'
  add_foreign_key 'grants', 'organizations'
  add_foreign_key 'users', 'organizations'
end
