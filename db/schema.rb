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

ActiveRecord::Schema.define(version: 20170724232941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "banned_addresses", id: false, force: :cascade do |t|
    t.string   "email",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_banned_addresses_on_email", unique: true, using: :btree
  end

  create_table "chapters", primary_key: ["story_id", "number"], force: :cascade do |t|
    t.integer  "story_id",   null: false
    t.integer  "number",     null: false
    t.string   "title"
    t.text     "body",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id"], name: "index_chapters_on_story_id", using: :btree
  end

  create_table "characters", force: :cascade do |t|
    t.integer  "source_id"
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id"], name: "index_characters_on_source_id", using: :btree
  end

  create_table "news_tags", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "newsposts", force: :cascade do |t|
    t.string   "admin",      null: false
    t.string   "title"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_newsposts_on_admin", using: :btree
  end

  create_table "sources", force: :cascade do |t|
    t.string   "name",                        null: false
    t.boolean  "book",        default: false
    t.boolean  "celeb",       default: false
    t.boolean  "music",       default: false
    t.boolean  "theater",     default: false
    t.boolean  "video_games", default: false
    t.boolean  "anime",       default: false
    t.boolean  "comics",      default: false
    t.boolean  "movies",      default: false
    t.boolean  "misc",        default: false
    t.boolean  "tv",          default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "stories", force: :cascade do |t|
    t.string   "title",                          null: false
    t.string   "author",                         null: false
    t.text     "summary"
    t.boolean  "adult_override", default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["author"], name: "index_stories_on_author", using: :btree
  end

  create_table "stories_tags", id: false, force: :cascade do |t|
    t.integer "story_id", null: false
    t.string  "name"
  end

  create_table "tags", id: false, force: :cascade do |t|
    t.string   "name",                       null: false
    t.boolean  "adult",      default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string   "name",                              null: false
    t.string   "email",                             null: false
    t.string   "password_digest"
    t.string   "confirmation_hash"
    t.boolean  "is_confirmed",      default: false
    t.boolean  "adult",             default: false
    t.boolean  "admin",             default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["name"], name: "index_users_on_name", unique: true, using: :btree
  end

  add_foreign_key "chapters", "stories", on_delete: :cascade
  add_foreign_key "characters", "sources"
  add_foreign_key "newsposts", "users", column: "admin", primary_key: "name"
  add_foreign_key "stories", "users", column: "author", primary_key: "name", on_delete: :cascade
end
