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

ActiveRecord::Schema.define(version: 20130612171525) do

  create_table "gemgento_addresses", force: true do |t|
    t.integer  "magento_id",                          null: false
    t.integer  "user_id",                             null: false
    t.string   "increment_id"
    t.string   "city"
    t.string   "company"
    t.integer  "country_id"
    t.string   "fax"
    t.string   "fname"
    t.string   "mname"
    t.string   "lname"
    t.string   "postcode"
    t.string   "prefix"
    t.string   "suffix"
    t.string   "region_name"
    t.integer  "region_id"
    t.string   "street"
    t.string   "telephone"
    t.boolean  "is_default_billing",  default: false, null: false
    t.boolean  "is_default_shipping", default: false, null: false
    t.boolean  "sync_needed",         default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_asset_types", force: true do |t|
    t.integer  "product_attribute_set_id"
    t.string   "code"
    t.string   "scope"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "gemgento_assets", force: true do |t|
    t.integer  "product_id"
    t.string   "url"
    t.integer  "position"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "file"
    t.string   "label"
    t.boolean  "sync_needed", default: true, null: false
  end

  create_table "gemgento_assets_asset_types", id: false, force: true do |t|
    t.integer "asset_id",      default: 0, null: false
    t.integer "asset_type_id", default: 0, null: false
  end

  create_table "gemgento_categories", force: true do |t|
    t.integer  "magento_id"
    t.string   "name"
    t.string   "url_key"
    t.integer  "parent_id"
    t.integer  "position"
    t.boolean  "is_active"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "all_children"
    t.string   "children"
    t.integer  "children_count"
    t.boolean  "sync_needed",     default: true, null: false
    t.boolean  "include_in_menu", default: true, null: false
  end

  add_index "gemgento_categories", ["magento_id"], name: "index_gemgento_categories_on_magento_id", unique: true

  create_table "gemgento_categories_products", id: false, force: true do |t|
    t.integer "product_id",  default: 0, null: false
    t.integer "category_id", default: 0, null: false
  end

  create_table "gemgento_configurable_attributes", id: false, force: true do |t|
    t.integer "product_id",           default: 0, null: false
    t.integer "product_attribute_id", default: 0, null: false
  end

  create_table "gemgento_countries", force: true do |t|
    t.string   "magento_id", null: false
    t.string   "iso2_code"
    t.string   "iso3_code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_inventories", force: true do |t|
    t.integer  "product_id",                  null: false
    t.integer  "quantity",    default: 0,     null: false
    t.boolean  "is_in_stock", default: false, null: false
    t.boolean  "sync_needed", default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_product_attribute_options", force: true do |t|
    t.integer  "product_attribute_id"
    t.string   "label"
    t.string   "value"
    t.boolean  "sync_needed",          default: true, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "gemgento_product_attribute_sets", force: true do |t|
    t.integer  "magento_id"
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "sync_needed", default: true, null: false
  end

  create_table "gemgento_product_attribute_values", force: true do |t|
    t.integer  "product_id"
    t.integer  "product_attribute_id"
    t.text     "value"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "gemgento_product_attributes", force: true do |t|
    t.integer  "magento_id"
    t.integer  "product_attribute_set_id",                     null: false
    t.string   "code"
    t.string   "frontend_input"
    t.string   "scope"
    t.boolean  "is_unique"
    t.boolean  "is_required"
    t.boolean  "is_configurable"
    t.boolean  "is_searchable"
    t.boolean  "is_visible_in_advanced_search"
    t.boolean  "is_comparable"
    t.boolean  "is_used_for_promo_rules"
    t.boolean  "is_visible_on_front"
    t.boolean  "used_in_product_listing"
    t.boolean  "sync_needed",                   default: true, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "gemgento_products", force: true do |t|
    t.integer  "magento_id"
    t.string   "magento_type"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "sku"
    t.string   "product_attribute_set_id"
    t.string   "store_id"
    t.boolean  "sync_needed",              default: true, null: false
    t.integer  "parent_id"
  end

  create_table "gemgento_regions", force: true do |t|
    t.integer  "magento_id", null: false
    t.string   "code"
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_sessions", force: true do |t|
    t.string   "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_stores", force: true do |t|
    t.integer  "magento_id",                null: false
    t.string   "code"
    t.integer  "group_id"
    t.string   "name"
    t.integer  "sort_order"
    t.boolean  "is_active",  default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_stores", ["magento_id"], name: "index_gemgento_stores_on_magento_id", unique: true

  create_table "gemgento_user_groups", force: true do |t|
    t.integer  "magento_id"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_users", force: true do |t|
    t.integer  "magento_id",                   null: false
    t.integer  "store_id",                     null: false
    t.string   "created_in"
    t.string   "email"
    t.string   "fname"
    t.string   "lname"
    t.string   "mname"
    t.integer  "user_group_id"
    t.string   "prefix"
    t.string   "suffix"
    t.date     "dob"
    t.string   "taxvat"
    t.boolean  "confirmation"
    t.string   "password"
    t.boolean  "sync_needed",   default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_users", ["magento_id"], name: "index_gemgento_users_on_magento_id", unique: true

end
