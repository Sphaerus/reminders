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

ActiveRecord::Schema.define(version: 20170322153936) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "check_assignments", force: :cascade do |t|
    t.integer  "project_check_id"
    t.integer  "user_id"
    t.date     "completion_date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "contact_person_id"
    t.date     "deadline"
    t.string   "note_url"
    t.index ["contact_person_id"], name: "index_check_assignments_on_contact_person_id", using: :btree
    t.index ["project_check_id"], name: "index_check_assignments_on_project_check_id", using: :btree
    t.index ["user_id"], name: "index_check_assignments_on_user_id", using: :btree
  end

  create_table "project_checks", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "reminder_id"
    t.date     "last_check_date"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "last_check_user_id"
    t.boolean  "enabled",                                 default: true
    t.text     "info"
    t.date     "last_check_date_without_disabled_period"
    t.date     "disabled_date"
    t.datetime "jira_issue_created_at"
    t.string   "jira_issue_key"
    t.index ["project_id"], name: "index_project_checks_on_project_id", using: :btree
    t.index ["reminder_id"], name: "index_project_checks_on_reminder_id", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",                        null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "channel_name"
    t.boolean  "enabled",      default: true
    t.string   "email"
    t.datetime "archived_at"
  end

  create_table "reminders", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "valid_for_n_days",         default: 30
    t.text     "remind_after_days",        default: [],                 array: true
    t.string   "deadline_text"
    t.string   "notification_text"
    t.string   "slack_channel"
    t.string   "supervisor_slack_channel"
    t.boolean  "notify_projects_channels", default: false, null: false
    t.integer  "jira_issue_lead",          default: 7
    t.integer  "order",                    default: 0
  end

  create_table "skills", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "reminder_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["reminder_id"], name: "index_skills_on_reminder_id", using: :btree
    t.index ["user_id"], name: "index_skills_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "admin",       default: false
    t.datetime "archived_at"
    t.string   "email"
    t.boolean  "paused",      default: false
  end

  add_foreign_key "check_assignments", "project_checks"
  add_foreign_key "check_assignments", "users"
  add_foreign_key "project_checks", "projects"
  add_foreign_key "project_checks", "reminders"
  add_foreign_key "skills", "reminders"
  add_foreign_key "skills", "users"
end
