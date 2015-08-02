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

ActiveRecord::Schema.define(version: 20150802150254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "check_assignments", force: :cascade do |t|
    t.integer  "project_check_id"
    t.integer  "user_id"
    t.date     "completion_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "check_assignments", ["project_check_id"], name: "index_check_assignments_on_project_check_id", using: :btree
  add_index "check_assignments", ["user_id"], name: "index_check_assignments_on_user_id", using: :btree

  create_table "project_checks", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "reminder_id"
    t.date     "last_check_date"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "last_check_user_id"
    t.boolean  "enabled",            default: true
  end

  add_index "project_checks", ["project_id"], name: "index_project_checks_on_project_id", using: :btree
  add_index "project_checks", ["reminder_id"], name: "index_project_checks_on_reminder_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                        null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "channel_name"
    t.boolean  "enabled",      default: true
  end

  create_table "reminders", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "valid_for_n_days",  default: 30
    t.text     "remind_after_days", default: [],              array: true
    t.string   "deadline_text"
    t.string   "notification_text"
  end

  create_table "skills", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "reminder_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "skills", ["reminder_id"], name: "index_skills_on_reminder_id", using: :btree
  add_index "skills", ["user_id"], name: "index_skills_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "admin",       default: false
    t.datetime "archived_at"
  end

  add_foreign_key "check_assignments", "project_checks"
  add_foreign_key "check_assignments", "users"
  add_foreign_key "project_checks", "projects"
  add_foreign_key "project_checks", "reminders"
  add_foreign_key "skills", "reminders"
  add_foreign_key "skills", "users"
end
