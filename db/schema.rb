# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131031152725) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_participants", force: true do |t|
    t.integer  "account_id"
    t.integer  "participant_id"
    t.boolean  "proxy",          default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "child",          default: false, null: false
  end

  add_index "account_participants", ["account_id"], name: "index_account_participants_on_account_id", using: :btree
  add_index "account_participants", ["participant_id"], name: "index_account_participants_on_participant_id", using: :btree

  create_table "accounts", force: true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count",       default: 0,  null: false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "perishable_token",  default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["email"], name: "accounts_email_idx", unique: true, using: :btree

  create_table "answers", force: true do |t|
    t.integer  "question_id"
    t.text     "text"
    t.text     "help_text"
    t.integer  "display_order"
    t.string   "reference"
    t.integer  "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consent_signatures", force: true do |t|
    t.integer  "consent_id"
    t.integer  "participant_id"
    t.date     "consent_date"
    t.string   "consent_person_name"
    t.boolean  "accept"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "consent_signatures", ["participant_id"], name: "index_consent_signatures_on_participant_id", using: :btree

  create_table "consents", force: true do |t|
    t.text     "content"
    t.string   "accept_text",  default: "I Accept"
    t.string   "decline_text", default: "I Decline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consent_type"
  end

  create_table "contact_logs", force: true do |t|
    t.integer  "participant_id"
    t.date     "date"
    t.string   "contacter"
    t.string   "mode"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", force: true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "primary_phone"
    t.string   "secondary_phone"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "do_not_contact"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stage"
    t.string   "primary_guardian_first_name"
    t.string   "primary_guardian_last_name"
    t.string   "primary_guardian_email"
    t.string   "primary_guardian_phone"
    t.string   "secondary_guardian_first_name"
    t.string   "secondary_guardian_last_name"
    t.string   "secondary_guardian_email"
    t.string   "secondary_guardian_phone"
  end

  create_table "questions", force: true do |t|
    t.integer  "survey_id"
    t.integer  "section_id"
    t.text     "text"
    t.string   "reference"
    t.boolean  "is_mandatory"
    t.string   "response_type"
    t.integer  "display_order"
    t.text     "help_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", force: true do |t|
    t.string   "category"
    t.integer  "origin_id"
    t.integer  "destination_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "response_sets", force: true do |t|
    t.integer  "survey_id"
    t.integer  "participant_id"
    t.date     "effective_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
  end

  create_table "responses", force: true do |t|
    t.integer  "response_set_id"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", force: true do |t|
    t.text    "parameters"
    t.string  "connector"
    t.integer "study_id"
    t.string  "state"
    t.date    "request_date"
    t.date    "process_date"
    t.date    "decline_date"
  end

  create_table "sections", force: true do |t|
    t.integer "survey_id"
    t.text    "title"
    t.integer "display_order"
  end

  create_table "studies", force: true do |t|
    t.string "irb_number"
    t.date   "active_on"
    t.date   "inactive_on"
  end

  create_table "study_involvements", force: true do |t|
    t.integer  "study_id"
    t.integer  "participant_id"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "netid"
    t.boolean  "admin"
    t.boolean  "researcher"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
