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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130503213539) do

  create_table "gemgento_assets", :force => true do |t|
    t.integer  "product_id"
    t.string   "type"
    t.string   "url"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "gemgento_categories", :force => true do |t|
    t.integer  "magento_id"
    t.string   "name"
    t.string   "url_key"
    t.integer  "parent_id"
    t.integer  "position"
    t.boolean  "is_active"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.text     "all_children"
    t.string   "children"
    t.integer  "children_count"
    t.boolean  "sync_needed",     :default => true, :null => false
    t.boolean  "include_in_menu", :default => true, :null => false
  end

  add_index "gemgento_categories", ["magento_id"], :name => "index_gemgento_categories_on_magento_id", :unique => true

  create_table "gemgento_products", :force => true do |t|
    t.integer  "magento_id"
    t.string   "name"
    t.string   "magento_type"
    t.string   "url_key"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.decimal  "price",        :precision => 10, :scale => 0
  end

  create_table "gemgento_sessions", :force => true do |t|
    t.string   "session_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
