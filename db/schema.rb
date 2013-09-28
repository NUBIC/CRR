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

ActiveRecord::Schema.define(version: 20130927115431) do

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

  create_table "contact_logs", force: true do |t|
    t.integer  "participant_id"
    t.date     "date"
    t.string   "contacter"
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
    t.date     "birthdate"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.date    "request_date"
    t.date    "request_process_date"
    t.date    "request_decline_date"
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

end
