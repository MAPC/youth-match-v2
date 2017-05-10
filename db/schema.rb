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

ActiveRecord::Schema.define(version: 20170418204247) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "applicants", force: :cascade do |t|
    t.string    "first_name"
    t.string    "last_name"
    t.string    "email"
    t.integer   "icims_id"
    t.string    "interests",                                                                                             array: true
    t.boolean   "prefers_nearby"
    t.boolean   "has_transit_pass"
    t.integer   "grid_id"
    t.geography "location",                        limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime  "created_at",                                                                               null: false
    t.datetime  "updated_at",                                                                               null: false
    t.integer   "lottery_number"
    t.boolean   "receive_text_messages"
    t.string    "mobile_phone"
    t.string    "guardian_name"
    t.string    "guardian_phone"
    t.string    "guardian_email"
    t.boolean   "in_school"
    t.string    "school_type"
    t.boolean   "bps_student"
    t.string    "bps_school_name"
    t.string    "current_grade_level"
    t.boolean   "english_first_language"
    t.string    "first_language"
    t.boolean   "fluent_other_language"
    t.string    "other_languages",                                                                                       array: true
    t.boolean   "held_successlink_job_before"
    t.string    "previous_job_site"
    t.boolean   "wants_to_return_to_previous_job"
    t.boolean   "superteen_participant"
    t.text      "participant_essay"
    t.string    "address"
    t.text      "participant_essay_attached_file"
    t.string    "home_phone"
    t.integer   "workflow_id"
    t.integer   "user_id"
    t.string    "neighborhood"
    t.index ["user_id"], name: "index_applicants_on_user_id", using: :btree
  end

  create_table "boxes", force: :cascade do |t|
    t.geometry "geom",      limit: {:srid=>4326, :type=>"multi_polygon"}
    t.integer  "g250m_id"
    t.string   "municipal"
    t.integer  "muni_id"
  end

  create_table "offers", force: :cascade do |t|
    t.integer  "applicant_id"
    t.integer  "position_id"
    t.integer  "accepted"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["applicant_id"], name: "index_offers_on_applicant_id", using: :btree
    t.index ["position_id"], name: "index_offers_on_position_id", using: :btree
  end

  create_table "picks", force: :cascade do |t|
    t.integer  "applicant_id"
    t.integer  "position_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "status"
    t.index ["applicant_id"], name: "index_picks_on_applicant_id", using: :btree
    t.index ["position_id"], name: "index_picks_on_position_id", using: :btree
  end

  create_table "positions", force: :cascade do |t|
    t.integer   "icims_id"
    t.string    "title"
    t.string    "category"
    t.integer   "grid_id"
    t.geography "location",                     limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime  "created_at",                                                                            null: false
    t.datetime  "updated_at",                                                                            null: false
    t.integer   "applicant_id"
    t.text      "duties_responsbilities"
    t.text      "ideal_candidate"
    t.integer   "open_positions"
    t.string    "site_name"
    t.string    "external_application_url"
    t.string    "primary_contact_person"
    t.string    "primary_contact_person_title"
    t.string    "primary_contact_person_phone"
    t.string    "site_phone"
    t.string    "address"
    t.string    "neighborhood"
    t.string    "primary_contact_person_email"
    t.string    "external_id"
    t.index ["applicant_id"], name: "index_positions_on_applicant_id", using: :btree
  end

  create_table "preferences", force: :cascade do |t|
    t.integer  "applicant_id"
    t.integer  "position_id"
    t.float    "score"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["applicant_id"], name: "index_preferences_on_applicant_id", using: :btree
    t.index ["position_id"], name: "index_preferences_on_position_id", using: :btree
  end

  create_table "rehire_sites", force: :cascade do |t|
    t.string   "site_name"
    t.string   "person_name"
    t.boolean  "should_rehire"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "icims_id"
  end

  create_table "requisitions", force: :cascade do |t|
    t.integer "applicant_id"
    t.integer "position_id"
    t.integer "status",       default: 0
  end

  create_table "sites", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "position_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["position_id"], name: "index_sites_on_position_id", using: :btree
    t.index ["user_id"], name: "index_sites_on_user_id", using: :btree
  end

  create_table "travel_times", force: :cascade do |t|
    t.integer "input_id"
    t.integer "target_id"
    t.integer "g250m_id_origin"
    t.integer "g250m_id_destination"
    t.decimal "distance"
    t.decimal "x_origin",             precision: 15, scale: 12
    t.decimal "y_origin",             precision: 15, scale: 12
    t.decimal "x_destination",        precision: 15, scale: 12
    t.decimal "y_destination",        precision: 15, scale: 12
    t.string  "travel_mode"
    t.integer "time"
    t.integer "pair_id"
    t.index ["input_id"], name: "index_travel_times_on_input_id", using: :btree
    t.index ["target_id"], name: "index_travel_times_on_target_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "authentication_token"
    t.integer  "allocation_rule",        default: 2
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "applicants", "users"
  add_foreign_key "picks", "applicants"
  add_foreign_key "picks", "positions"
  add_foreign_key "positions", "applicants"
  add_foreign_key "preferences", "applicants"
  add_foreign_key "preferences", "positions"
end
