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

ActiveRecord::Schema.define(version: 20131010200128) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chat_histories", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "project_id",             null: false
    t.integer  "type",       default: 0, null: false
    t.json     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chat_histories", ["project_id"], name: "index_chat_histories_on_project_id", using: :btree
  add_index "chat_histories", ["user_id"], name: "index_chat_histories_on_user_id", using: :btree

  create_table "friendships", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "friend_id",              null: false
    t.integer  "status",     default: 0, null: false
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id", "user_id"], name: "index_friendships_on_friend_id_and_user_id", unique: true, using: :btree
  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["status"], name: "index_friendships_on_status", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "invitations", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "code"
    t.string   "email"
    t.text     "message"
    t.integer  "invitation_type"
    t.integer  "status",          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["code"], name: "index_invitations_on_code", using: :btree
  add_index "invitations", ["project_id"], name: "index_invitations_on_project_id", using: :btree
  add_index "invitations", ["user_id"], name: "index_invitations_on_user_id", using: :btree

  create_table "places", force: true do |t|
    t.text     "notes"
    t.string   "name"
    t.text     "address"
    t.string   "coord",                  null: false
    t.integer  "order",      default: 0, null: false
    t.integer  "project_id",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "reference"
    t.integer  "user_id",                null: false
  end

  add_index "places", ["project_id"], name: "index_places_on_project_id", using: :btree
  add_index "places", ["user_id"], name: "index_places_on_user_id", using: :btree

  create_table "project_participations", force: true do |t|
    t.integer  "project_id",             null: false
    t.integer  "user_id",                null: false
    t.integer  "status",     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_participations", ["project_id", "user_id"], name: "index_project_participations_on_project_id_and_user_id", unique: true, using: :btree
  add_index "project_participations", ["project_id"], name: "index_project_participations_on_project_id", using: :btree
  add_index "project_participations", ["user_id"], name: "index_project_participations_on_user_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "title",      default: "Untitled map", null: false
    t.text     "notes"
    t.integer  "owner_id",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["owner_id"], name: "index_projects_on_owner_id", using: :btree
  add_index "projects", ["title"], name: "index_projects_on_title", using: :btree

  create_table "remember_logins", force: true do |t|
    t.string   "remember_token", null: false
    t.integer  "user_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "login_type",     null: false
  end

  add_index "remember_logins", ["remember_token", "user_id"], name: "index_remember_logins_on_remember_token_and_user_id", unique: true, using: :btree
  add_index "remember_logins", ["remember_token"], name: "index_remember_logins_on_remember_token", using: :btree
  add_index "remember_logins", ["user_id"], name: "index_remember_logins_on_user_id", using: :btree

  create_table "reset_password_tokens", force: true do |t|
    t.string   "reset_token", null: false
    t.string   "user_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reset_password_tokens", ["reset_token"], name: "index_reset_password_tokens_on_reset_token", unique: true, using: :btree
  add_index "reset_password_tokens", ["user_id"], name: "index_reset_password_tokens_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",            null: false
    t.string   "email"
    t.text     "fb_access_token"
    t.string   "fb_user_id"
    t.text     "profile_picture"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_hash"
    t.string   "password_salt"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["fb_user_id"], name: "index_users_on_fb_user_id", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree

end
