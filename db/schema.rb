# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_01_23_171240) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_actions", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "controller", null: false
    t.string "action", null: false
    t.string "browser"
    t.string "params"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["controller", "action"], name: "index_audit_actions_on_controller_and_action"
    t.index ["user_id", "action"], name: "index_audit_actions_on_user_id_and_action"
    t.index ["user_id", "controller"], name: "index_audit_actions_on_user_id_and_controller"
  end

  create_table "banner_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["item_id"], name: "index_banner_versions_on_item_id"
    t.index ["whodunnit"], name: "index_banner_versions_on_whodunnit"
  end

  create_table "banners", force: :cascade do |t|
    t.text "body"
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "criteria", force: :cascade do |t|
    t.bigint "grant_id"
    t.string "name"
    t.text "description"
    t.boolean "is_mandatory", default: true, null: false
    t.boolean "show_comment_field", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_criteria_on_grant_id"
  end

  create_table "criteria_review_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "review_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["item_id"], name: "index_criteria_review_versions_on_item_id"
    t.index ["review_id"], name: "index_criteria_review_versions_on_review_id"
    t.index ["whodunnit"], name: "index_criteria_review_versions_on_whodunnit"
  end

  create_table "criteria_reviews", force: :cascade do |t|
    t.bigint "criterion_id"
    t.bigint "review_id"
    t.integer "score"
    t.text "comment"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["criterion_id"], name: "index_criteria_reviews_on_criterion_id"
    t.index ["review_id"], name: "index_criteria_reviews_on_review_id"
  end

  create_table "criterion_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_criterion_versions_on_grant_id"
    t.index ["item_id"], name: "index_criterion_versions_on_item_id"
    t.index ["whodunnit"], name: "index_criterion_versions_on_whodunnit"
  end

  create_table "grant_creator_request_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "requester_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["item_id"], name: "index_grant_creator_request_versions_on_item_id"
    t.index ["requester_id"], name: "index_grant_creator_request_versions_on_requester_id"
    t.index ["whodunnit"], name: "index_grant_creator_request_versions_on_whodunnit"
  end

  create_table "grant_creator_requests", force: :cascade do |t|
    t.bigint "requester_id", null: false
    t.text "request_comment", null: false
    t.string "status", default: "pending", null: false
    t.bigint "reviewer_id"
    t.text "review_comment"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["status"], name: "index_grant_creator_requests_on_status"
  end

  create_table "grant_permission_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.integer "user_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_grant_permission_versions_on_grant_id"
    t.index ["item_id"], name: "index_grant_permission_versions_on_item_id"
    t.index ["user_id"], name: "index_grant_permission_versions_on_user_id"
    t.index ["whodunnit"], name: "index_grant_permission_versions_on_whodunnit"
  end

  create_table "grant_permissions", force: :cascade do |t|
    t.bigint "grant_id"
    t.bigint "user_id"
    t.string "role"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "submission_notification", default: false, null: false
    t.boolean "contact", default: false, null: false
    t.index ["grant_id"], name: "index_grant_permissions_on_grant_id"
    t.index ["user_id"], name: "index_grant_permissions_on_user_id"
  end

  create_table "grant_reviewer_invitation_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.string "email", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["email"], name: "index_grant_reviewer_invitation_versions_on_email"
    t.index ["grant_id"], name: "index_grant_reviewer_invitation_versions_on_grant_id"
    t.index ["item_id"], name: "index_grant_reviewer_invitation_versions_on_item_id"
    t.index ["whodunnit"], name: "index_grant_reviewer_invitation_versions_on_whodunnit"
  end

  create_table "grant_reviewer_invitations", force: :cascade do |t|
    t.bigint "grant_id", null: false
    t.bigint "invited_by_id", null: false
    t.bigint "invitee_id"
    t.string "email", null: false
    t.datetime "confirmed_at", precision: nil
    t.datetime "reminded_at", precision: nil
    t.datetime "opted_out_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_grant_reviewer_invitations_on_email"
    t.index ["grant_id", "email"], name: "index_grant_reviewer_invitations_on_grant_id_and_email", unique: true
    t.index ["grant_id", "invited_by_id"], name: "index_grant_reviewer_invitations_on_grant_id_and_invited_by_id"
    t.index ["grant_id"], name: "index_grant_reviewer_invitations_on_grant_id"
  end

  create_table "grant_reviewer_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.integer "reviewer_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_grant_reviewer_versions_on_grant_id"
    t.index ["item_id"], name: "index_grant_reviewer_versions_on_item_id"
    t.index ["reviewer_id"], name: "index_grant_reviewer_versions_on_reviewer_id"
    t.index ["whodunnit"], name: "index_grant_reviewer_versions_on_whodunnit"
  end

  create_table "grant_reviewers", force: :cascade do |t|
    t.bigint "grant_id", null: false
    t.bigint "reviewer_id", null: false
    t.index ["grant_id"], name: "index_grant_reviewers_on_grant_id"
    t.index ["reviewer_id"], name: "index_grant_reviewers_on_reviewer_id"
  end

  create_table "grant_submission_form_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_grant_submission_form_versions_on_grant_id"
    t.index ["item_id"], name: "index_grant_submission_form_versions_on_item_id"
    t.index ["whodunnit"], name: "index_grant_submission_form_versions_on_whodunnit"
  end

  create_table "grant_submission_forms", force: :cascade do |t|
    t.bigint "grant_id"
    t.string "submission_instructions", limit: 3000
    t.bigint "created_id"
    t.bigint "updated_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_grant_submission_forms_on_grant_id", unique: true
  end

  create_table "grant_submission_multiple_choice_option_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_submission_question_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_submission_question_id"], name: "i_gsmcov_on_question_id"
    t.index ["item_id"], name: "i_gsmcov_on_item_id"
    t.index ["whodunnit"], name: "i_gsmcov_on_whodunnit"
  end

  create_table "grant_submission_multiple_choice_options", force: :cascade do |t|
    t.bigint "grant_submission_question_id", null: false
    t.string "text", null: false
    t.integer "display_order", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["display_order", "grant_submission_question_id"], name: "i_smco_on_display_order_and_submission_question_id", unique: true
    t.index ["grant_submission_question_id"], name: "i_gsmco_on_submission_question_id"
    t.index ["text", "grant_submission_question_id"], name: "i_smco_on_text_and_submission_question_id", unique: true
  end

  create_table "grant_submission_question_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_submission_section_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_submission_section_id"], name: "index_gsqv_on_section_id"
    t.index ["item_id"], name: "index_gsqv_on_item_id"
    t.index ["whodunnit"], name: "index_gsqv_on_whodunnit"
  end

  create_table "grant_submission_questions", force: :cascade do |t|
    t.bigint "grant_submission_section_id", null: false
    t.string "text", limit: 4000, null: false
    t.string "instruction", limit: 4000
    t.integer "display_order", null: false
    t.string "export_code"
    t.boolean "is_mandatory"
    t.string "response_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["display_order", "grant_submission_section_id"], name: "i_sqs_on_display_order_and_submission_section_id", unique: true
    t.index ["grant_submission_section_id"], name: "index_grant_submission_questions_on_grant_submission_section_id"
    t.index ["text", "grant_submission_section_id"], name: "i_gsq_on_text_and_grant_submission_section_id", unique: true
  end

  create_table "grant_submission_response_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_submission_question_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_submission_question_id"], name: "index_gsrv_on_question_id"
    t.index ["item_id"], name: "index_gsrv_on_item_id"
    t.index ["whodunnit"], name: "index_gsrv_on_whodunnit"
  end

  create_table "grant_submission_responses", force: :cascade do |t|
    t.bigint "grant_submission_submission_id", null: false
    t.bigint "grant_submission_question_id", null: false
    t.bigint "grant_submission_multiple_choice_option_id"
    t.string "string_val"
    t.text "text_val"
    t.decimal "decimal_val"
    t.datetime "datetime_val", precision: nil
    t.boolean "boolean_val"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["grant_submission_multiple_choice_option_id"], name: "i_gsr_on_submission_multiple_choice_option_id"
    t.index ["grant_submission_question_id", "grant_submission_submission_id"], name: "i_gsr_on_submissisubmission_id", unique: true
    t.index ["grant_submission_question_id"], name: "i_gsr_on_grant_submission_question_id"
    t.index ["grant_submission_submission_id"], name: "i_gsr_on_grant_submission_submission_id"
  end

  create_table "grant_submission_section_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_submission_form_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_submission_form_id"], name: "index_gssv_on_form_id"
    t.index ["item_id"], name: "index_gssv_on_item_id"
    t.index ["whodunnit"], name: "index_gssv_on_whodunnit"
  end

  create_table "grant_submission_sections", force: :cascade do |t|
    t.bigint "grant_submission_form_id", null: false
    t.string "title"
    t.integer "display_order", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["display_order", "grant_submission_form_id"], name: "i_submission_sections_on_display_order_and_submission_form_id", unique: true
    t.index ["grant_submission_form_id"], name: "index_grant_submission_sections_on_grant_submission_form_id"
  end

  create_table "grant_submission_submission_applicant_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_submission_submission_id", null: false
    t.integer "applicant_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["applicant_id"], name: "index_gs_submission_applicant_v_on_applicant_id"
    t.index ["grant_submission_submission_id"], name: "index_gs_submission_applicant_v_on_submission_id"
    t.index ["item_id"], name: "index_gs_submission_applicant_v_on_item_id"
    t.index ["whodunnit"], name: "index_gs_submission_applicant_v_on_whodunnit"
  end

  create_table "grant_submission_submission_applicants", force: :cascade do |t|
    t.bigint "grant_submission_submission_id", null: false
    t.bigint "applicant_id", null: false
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_grant_submission_submission_applicants_on_applicant_id"
    t.index ["grant_submission_submission_id"], name: "i_gssa_on_grant_submission_submission_id"
  end

  create_table "grant_submission_submission_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.integer "submitter_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_id", "submitter_id"], name: "index_gs_submission_v_on_grant_id_submitter_id"
    t.index ["grant_id"], name: "index_gs_submission_v_on_grant_id"
    t.index ["item_id"], name: "index_gs_submission_v_on_item_id"
    t.index ["whodunnit"], name: "index_gs_submission_v_on_whodunnit"
  end

  create_table "grant_submission_submissions", force: :cascade do |t|
    t.bigint "grant_id", null: false
    t.bigint "grant_submission_form_id", null: false
    t.bigint "created_id", null: false
    t.string "title", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "reviews_count", default: 0
    t.string "state", null: false
    t.datetime "user_updated_at", precision: nil
    t.datetime "discarded_at", precision: nil
    t.decimal "average_overall_impact_score", precision: 5, scale: 2
    t.decimal "composite_score", precision: 5, scale: 2
    t.boolean "awarded", default: false, null: false
    t.index ["created_id", "grant_submission_form_id"], name: "i_gss_on_created_id_and_submission_form_id"
    t.index ["discarded_at"], name: "index_grant_submission_submissions_on_discarded_at"
    t.index ["grant_id", "awarded"], name: "index_grant_submission_submissions_on_grant_id_and_awarded"
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
    t.datetime "created_at", precision: nil, null: false
    t.index ["item_type", "item_id"], name: "index_grant_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "index_grant_versions_on_whodunnit"
  end

  create_table "grants", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "state", null: false
    t.date "publish_date", null: false
    t.date "submission_open_date", null: false
    t.date "submission_close_date", null: false
    t.text "rfa"
    t.integer "applications_per_user"
    t.text "review_guidance"
    t.integer "max_reviewers_per_submission"
    t.integer "max_submissions_per_reviewer"
    t.date "review_open_date"
    t.date "review_close_date"
    t.datetime "discarded_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discarded_at"], name: "index_grants_on_discarded_at"
    t.index ["slug"], name: "index_grants_on_slug"
  end

  create_table "panel_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_panel_versions_on_grant_id"
    t.index ["item_id"], name: "index_panel_versions_on_item_id"
    t.index ["whodunnit"], name: "index_panel_versions_on_whodunnit"
  end

  create_table "panels", force: :cascade do |t|
    t.bigint "grant_id", null: false
    t.datetime "start_datetime", precision: nil
    t.datetime "end_datetime", precision: nil
    t.text "instructions"
    t.string "meeting_link"
    t.text "meeting_location"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "discarded_at", precision: nil
    t.boolean "show_review_comments", default: false, null: false
    t.index ["discarded_at"], name: "index_panels_on_discarded_at"
    t.index ["grant_id"], name: "index_panels_on_grant_id"
  end

  create_table "review_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.integer "reviewer_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_review_versions_on_grant_id"
    t.index ["item_id"], name: "index_review_versions_on_item_id"
    t.index ["whodunnit"], name: "index_review_versions_on_whodunnit"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "grant_submission_submission_id", null: false
    t.bigint "assigner_id", null: false
    t.bigint "reviewer_id", null: false
    t.integer "overall_impact_score"
    t.text "overall_impact_comment"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "discarded_at", precision: nil
    t.datetime "reminded_at", precision: nil
    t.string "state", default: "assigned", null: false
    t.index ["discarded_at"], name: "index_reviews_on_discarded_at"
    t.index ["grant_submission_submission_id", "reviewer_id"], name: "index_review_reviewer_on_grant_submission_id_and_assigner_id", unique: true
    t.index ["grant_submission_submission_id"], name: "index_reviews_on_grant_submission_submission_id"
    t.index ["state"], name: "index_reviews_on_state"
  end

  create_table "user_versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "user_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil, null: false
    t.index ["item_id"], name: "index_user_versions_on_item_id"
    t.index ["whodunnit"], name: "index_user_versions_on_whodunnit"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "era_commons"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "system_admin", default: false, null: false
    t.boolean "grant_creator", default: false, null: false
    t.string "uid", default: "", null: false
    t.string "type"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "criteria_reviews", "criteria"
  add_foreign_key "criteria_reviews", "reviews"
  add_foreign_key "grant_permissions", "grants"
  add_foreign_key "grant_permissions", "users"
  add_foreign_key "grant_submission_forms", "grants"
  add_foreign_key "grant_submission_questions", "grant_submission_sections"
  add_foreign_key "grant_submission_submission_applicants", "grant_submission_submissions"
  add_foreign_key "panels", "grants"
  add_foreign_key "reviews", "grant_submission_submissions"
end
