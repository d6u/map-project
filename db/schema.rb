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

ActiveRecord::Schema.define(version: 20130806040145) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.integer  "status",     default: 0
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id", "user_id"], name: "index_friendships_on_friend_id_and_user_id", unique: true, using: :btree
  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["status"], name: "index_friendships_on_status", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "invitations", force: true do |t|
    t.string   "code"
    t.integer  "user_id"
    t.integer  "project_id"
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
    t.string   "coord"
    t.integer  "order"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["project_id"], name: "index_places_on_project_id", using: :btree

  create_table "project_user", force: true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "project_user", ["project_id", "user_id"], name: "index_project_user_on_project_id_and_user_id", unique: true, using: :btree
  add_index "project_user", ["project_id"], name: "index_project_user_on_project_id", using: :btree
  add_index "project_user", ["user_id"], name: "index_project_user_on_user_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "title"
    t.text     "notes"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["owner_id"], name: "index_projects_on_owner_id", using: :btree
  add_index "projects", ["title"], name: "index_projects_on_title", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "fb_access_token"
    t.string   "fb_user_id"
    t.string   "fb_user_picture"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["fb_user_id"], name: "index_users_on_fb_user_id", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree

end
