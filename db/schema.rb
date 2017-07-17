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

ActiveRecord::Schema.define(version: 20170710181144) do

  create_table "chapters", force: :cascade do |t|
    t.integer  "story_id"
    t.integer  "number",     null: false
    t.string   "title"
    t.text     "body",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id"], name: "index_chapters_on_story_id"
  end

  create_table "characters", force: :cascade do |t|
    t.integer "source_id"
    t.string  "name",      null: false
    t.index ["source_id"], name: "index_characters_on_source_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string   "name"
    t.boolean  "book"
    t.boolean  "celeb"
    t.boolean  "music"
    t.boolean  "theater"
    t.boolean  "video_games"
    t.boolean  "anime"
    t.boolean  "comics"
    t.boolean  "movies"
    t.boolean  "misc"
    t.boolean  "tv"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "stories", force: :cascade do |t|
    t.string   "title",                      null: false
    t.string   "author",                     null: false
    t.text     "summary",        limit: 500
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "adult_override"
  end

  create_table "stories_tags", id: false, force: :cascade do |t|
    t.integer "story_id", null: false
    t.integer "tag_id",   null: false
  end

  create_table "story_tags", force: :cascade do |t|
    t.integer  "story_id"
    t.string   "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.boolean  "adult"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string   "name",                              null: false
    t.string   "email",                             null: false
    t.string   "password_digest"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "confirmation_hash"
    t.boolean  "is_confirmed",      default: false
    t.boolean  "adult"
    t.index ["name"], name: "index_users_on_name", unique: true
  end

end
