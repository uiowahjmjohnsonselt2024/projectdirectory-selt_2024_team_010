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

ActiveRecord::Schema.define(version: 20241209151835) do

  create_table "characters", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.integer "level",      default: 1
    t.integer "health",     default: 5
    t.integer "x_position"
    t.integer "y_position"
  end

  create_table "games", force: :cascade do |t|
    t.string  "name"
    t.integer "owner_id"
    t.integer "max_user_count"
  end

  create_table "items", force: :cascade do |t|
    t.string  "item_type"
    t.string  "name"
    t.string  "description"
    t.integer "level"
    t.integer "character_id"
  end

  create_table "payments", force: :cascade do |t|
    t.float    "money_usd"
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_token"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "tiles", force: :cascade do |t|
    t.integer "game_id"
    t.integer "x_position"
    t.integer "y_position"
    t.string  "biome"
    t.string  "picture"
    t.string  "scene_description"
    t.string  "treasure_description"
    t.string  "monster_description"
    t.integer "visitor_id"
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
    t.string   "recent_character"
  end

end
