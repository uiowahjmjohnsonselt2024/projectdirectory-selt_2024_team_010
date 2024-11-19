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

ActiveRecord::Schema.define(version: 20241119160445) do

  create_table "games", force: :cascade do |t|
    t.string "name"
  end

  create_table "games_users", id: false, force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "user_id", null: false
  end

  add_index "games_users", ["game_id", "user_id"], name: "index_games_users_on_game_id_and_user_id"
  add_index "games_users", ["user_id", "game_id"], name: "index_games_users_on_user_id_and_game_id"

  create_table "sessions", force: :cascade do |t|
    t.string   "session_token"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.float    "shard_amount"
    t.float    "money_usd"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session"
  end

end
