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

ActiveRecord::Schema.define(version: 20140727074112) do

  create_table "file_structures", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path"
    t.integer  "bytes"
    t.datetime "ctime"
    t.datetime "mtime"
    t.string   "entity_type"
    t.integer  "file_count"
    t.integer  "item_count"
    t.integer  "mime_id"
    t.integer  "kind_id"
    t.string   "osx_tags"
    t.string   "fshugo_tags"
  end

  create_table "fshugo_tabs", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kind_tabs", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kind_tabs", ["description"], name: "index_kind_tabs_on_description", unique: true

  create_table "mime_tabs", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mime_tabs", ["description"], name: "index_mime_tabs_on_description", unique: true

  create_table "osx_tabs", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
