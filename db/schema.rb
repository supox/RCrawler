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

ActiveRecord::Schema.define(version: 20140802143524) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adjustments", force: true do |t|
    t.decimal  "size"
    t.string   "color"
    t.string   "clarity"
    t.integer  "cut_vg"
    t.integer  "cut_g"
    t.integer  "sym_vg"
    t.integer  "sym_g"
    t.integer  "pol_vg"
    t.integer  "pol_g"
    t.integer  "flor_faint"
    t.integer  "flor_medium"
    t.integer  "flor_strong"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", force: true do |t|
    t.string   "email",              default: "", null: false
    t.string   "encrypted_password", default: "", null: false
    t.integer  "sign_in_count",      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree

  create_table "diamonds", force: true do |t|
    t.string   "shape"
    t.decimal  "size"
    t.string   "color"
    t.string   "clarity"
    t.string   "cut"
    t.string   "polish"
    t.string   "sym"
    t.string   "flour"
    t.integer  "number_of_results"
    t.integer  "rap_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "diamonds", ["size", "color", "clarity", "cut", "polish", "sym", "flour"], name: "index_params_match", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.string   "rap_username"
    t.string   "rap_password"
    t.integer  "price_list_extra_discount"
    t.integer  "price_list_min_number_of_results_to_display"
    t.boolean  "start_xvfb"
    t.decimal  "ranges_size_start"
    t.decimal  "ranges_size_end"
    t.string   "ranges_cut",                                  array: true
    t.string   "ranges_polish",                               array: true
    t.string   "ranges_sym",                                  array: true
    t.string   "ranges_clarity",                              array: true
    t.string   "ranges_color_start"
    t.string   "ranges_color_end"
    t.string   "ranges_flour",                                array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sleep_time"
  end

end
