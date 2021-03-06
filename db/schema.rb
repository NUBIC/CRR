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

ActiveRecord::Schema.define(version: 2018_06_07_160201) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_participants", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "participant_id"
    t.boolean "proxy", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_account_participants_on_account_id"
    t.index ["participant_id"], name: "index_account_participants_on_participant_id"
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "crypted_password", limit: 255
    t.string "password_salt", limit: 255
    t.string "persistence_token", limit: 255
    t.integer "login_count", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string "last_login_ip", limit: 255
    t.string "current_login_ip", limit: 255
    t.string "perishable_token", limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "accounts_email_idx", unique: true
  end

  create_table "answers", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.text "text"
    t.text "help_text"
    t.integer "display_order"
    t.string "code", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "date"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id", "commentable_type"], name: "commentable_idx"
  end

  create_table "consent_signatures", id: :serial, force: :cascade do |t|
    t.integer "consent_id"
    t.integer "participant_id"
    t.date "date"
    t.string "proxy_name", limit: 255
    t.string "proxy_relationship", limit: 255
    t.string "entered_by", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["participant_id"], name: "index_consent_signatures_on_participant_id"
  end

  create_table "consents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "state", limit: 255
    t.string "accept_text", limit: 255, default: "I Accept"
    t.string "decline_text", limit: 255, default: "I Decline"
    t.string "consent_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "comment"
  end

  create_table "contact_logs", id: :serial, force: :cascade do |t|
    t.integer "participant_id"
    t.date "date"
    t.string "contacter", limit: 255
    t.string "mode", limit: 255
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "downloads", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "date"
    t.integer "study_involvement_id"
    t.string "consent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "email_notifications", id: :serial, force: :cascade do |t|
    t.string "state", limit: 255
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
    t.string "name"
    t.string "subject"
  end

  create_table "participants", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "primary_phone", limit: 255
    t.string "secondary_phone", limit: 255
    t.string "address_line1", limit: 255
    t.string "address_line2", limit: 255
    t.string "city", limit: 255
    t.string "state", limit: 255
    t.string "zip", limit: 255
    t.string "stage", limit: 255
    t.boolean "do_not_contact"
    t.boolean "child"
    t.text "notes"
    t.string "primary_guardian_first_name", limit: 255
    t.string "primary_guardian_last_name", limit: 255
    t.string "primary_guardian_email", limit: 255
    t.string "primary_guardian_phone", limit: 255
    t.string "secondary_guardian_first_name", limit: 255
    t.string "secondary_guardian_last_name", limit: 255
    t.string "secondary_guardian_email", limit: 255
    t.string "secondary_guardian_phone", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "hear_about_registry", limit: 255
    t.integer "origin_relationships_count", default: 0
    t.integer "destination_relationships_count", default: 0
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.integer "section_id"
    t.text "text"
    t.string "code", limit: 255
    t.boolean "is_mandatory"
    t.string "response_type", limit: 255
    t.integer "display_order"
    t.text "help_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", id: :serial, force: :cascade do |t|
    t.string "category", limit: 255
    t.integer "origin_id"
    t.integer "destination_id"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "response_sets", id: :serial, force: :cascade do |t|
    t.integer "survey_id"
    t.integer "participant_id"
    t.datetime "completed_at"
    t.boolean "public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", limit: 255
  end

  create_table "responses", id: :serial, force: :cascade do |t|
    t.integer "response_set_id"
    t.integer "question_id"
    t.integer "answer_id"
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file_upload"
  end

  create_table "search_condition_groups", id: :serial, force: :cascade do |t|
    t.integer "search_id"
    t.integer "search_condition_group_id"
    t.string "operator", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_conditions", id: :serial, force: :cascade do |t|
    t.integer "search_condition_group_id"
    t.string "operator", limit: 255
    t.integer "question_id"
    t.text "values"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_participant_study_involvements", id: :serial, force: :cascade do |t|
    t.integer "study_involvement_id"
    t.integer "search_participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "search_participants", id: :serial, force: :cascade do |t|
    t.integer "search_id"
    t.integer "participant_id"
    t.boolean "released", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["participant_id"], name: "index_search_participants_on_participant_id"
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.integer "study_id"
    t.string "state", limit: 255
    t.date "request_date"
    t.date "process_date"
    t.date "decline_date"
    t.date "start_date"
    t.date "warning_date"
    t.date "end_date"
    t.string "name", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "return_approved_date"
    t.date "return_completed_date"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "sections", id: :serial, force: :cascade do |t|
    t.integer "survey_id"
    t.text "title"
    t.integer "display_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", limit: 255, null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "studies", id: :serial, force: :cascade do |t|
    t.string "irb_number", limit: 255
    t.string "name", limit: 255
    t.string "pi_name", limit: 255
    t.string "pi_email", limit: 255
    t.text "other_investigators"
    t.string "contact_name", limit: 255
    t.string "contact_email", limit: 255
    t.string "short_title", limit: 255
    t.string "sites", limit: 255
    t.string "funding_source", limit: 255
    t.string "website", limit: 255
    t.date "start_date"
    t.date "end_date"
    t.integer "min_age"
    t.integer "max_age"
    t.integer "accrual_goal"
    t.integer "number_of_visits"
    t.text "protocol_goals"
    t.text "inclusion_criteria"
    t.text "exclusion_criteria"
    t.text "notes"
    t.string "state", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_involvement_statuses", id: :serial, force: :cascade do |t|
    t.integer "study_involvement_id"
    t.string "name"
    t.date "date"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_involvements", id: :serial, force: :cascade do |t|
    t.integer "study_id"
    t.integer "participant_id"
    t.date "start_date"
    t.date "end_date"
    t.date "warning_date"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "extended_release", default: false
  end

  create_table "surveys", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "description"
    t.text "state"
    t.string "code", limit: 255
    t.boolean "multiple_section"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "tier_2", default: false, null: false
  end

  create_table "user_studies", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "netid", limit: 255
    t.boolean "admin"
    t.boolean "researcher"
    t.boolean "data_manager"
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "email", limit: 255
    t.string "state"
    t.index ["netid"], name: "index_users_on_netid", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.string "whodunnit", limit: 255
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
