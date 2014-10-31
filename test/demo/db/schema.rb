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

ActiveRecord::Schema.define(version: 20141031140508) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "gemgento_addresses", force: true do |t|
    t.string   "addressable_type"
    t.integer  "addressable_id"
    t.integer  "magento_id"
    t.string   "increment_id"
    t.string   "city"
    t.string   "company"
    t.integer  "country_id"
    t.string   "fax"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "postcode"
    t.string   "prefix"
    t.string   "suffix"
    t.string   "region_name"
    t.integer  "region_id"
    t.string   "street"
    t.string   "telephone"
    t.boolean  "sync_needed",      default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_billing",       default: false
    t.boolean  "is_shipping",      default: false
  end

  add_index "gemgento_addresses", ["addressable_id", "addressable_type"], name: "index_gemgento_addresses_on_addressable_id_and_addressable_type", using: :btree

  create_table "gemgento_api_jobs", force: true do |t|
    t.integer  "source_id"
    t.string   "kind"
    t.string   "state"
    t.string   "source_type"
    t.string   "request_url"
    t.text     "request",         limit: 2147483647
    t.text     "response",        limit: 2147483647
    t.boolean  "locked"
    t.text     "request_body",    limit: 2147483647
    t.string   "request_status"
    t.string   "response_status"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_asset_files", force: true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.text     "file_meta"
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
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "file"
    t.string   "label"
    t.boolean  "sync_needed",   default: true, null: false
    t.integer  "store_id"
    t.integer  "asset_file_id"
  end

  add_index "gemgento_assets", ["product_id"], name: "index_gemgento_assets_on_product_id", using: :btree
  add_index "gemgento_assets", ["store_id"], name: "index_gemgento_assets_on_store_id", using: :btree

  create_table "gemgento_assets_asset_types", id: false, force: true do |t|
    t.integer "asset_id",      default: 0, null: false
    t.integer "asset_type_id", default: 0, null: false
  end

  create_table "gemgento_attribute_set_attributes", id: false, force: true do |t|
    t.integer "product_attribute_set_id", default: 0, null: false
    t.integer "product_attribute_id",     default: 0, null: false
  end

  add_index "gemgento_attribute_set_attributes", ["product_attribute_id"], name: "attribute_set_product_attributes_index", using: :btree
  add_index "gemgento_attribute_set_attributes", ["product_attribute_set_id", "product_attribute_id"], name: "attribute_set_attributes_index", unique: true, using: :btree

  create_table "gemgento_categories", force: true do |t|
    t.integer  "magento_id"
    t.string   "name"
    t.string   "url_key"
    t.integer  "parent_id"
    t.integer  "position"
    t.boolean  "is_active"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "all_children"
    t.integer  "children_count"
    t.boolean  "sync_needed",        default: true, null: false
    t.boolean  "include_in_menu",    default: true, null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "deleted_at"
    t.text     "image_meta"
  end

  add_index "gemgento_categories", ["magento_id"], name: "index_gemgento_categories_on_magento_id", unique: true, using: :btree

  create_table "gemgento_categories_stores", force: true do |t|
    t.integer "category_id"
    t.integer "store_id"
  end

  add_index "gemgento_categories_stores", ["category_id", "store_id"], name: "categories_index", unique: true, using: :btree
  add_index "gemgento_categories_stores", ["store_id"], name: "category_store_index", using: :btree

  create_table "gemgento_configurable_attributes", id: false, force: true do |t|
    t.integer "product_id",           default: 0, null: false
    t.integer "product_attribute_id", default: 0, null: false
  end

  add_index "gemgento_configurable_attributes", ["product_attribute_id"], name: "configurable_attribute_product_attribute_index", using: :btree
  add_index "gemgento_configurable_attributes", ["product_id", "product_attribute_id"], name: "configurable_attributes_index", unique: true, using: :btree

  create_table "gemgento_configurable_simple_relations", id: false, force: true do |t|
    t.integer "configurable_product_id", default: 0, null: false
    t.integer "simple_product_id",       default: 0, null: false
  end

  add_index "gemgento_configurable_simple_relations", ["configurable_product_id", "simple_product_id"], name: "configurable_simple_index", unique: true, using: :btree

  create_table "gemgento_countries", force: true do |t|
    t.string   "magento_id", null: false
    t.string   "iso2_code"
    t.string   "iso3_code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_footer_items", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_gift_messages", force: true do |t|
    t.integer "magento_id"
    t.string  "to"
    t.string  "from"
    t.text    "message"
  end

  create_table "gemgento_image_imports", force: true do |t|
    t.text     "import_errors"
    t.string   "spreadsheet_file_name"
    t.string   "spreadsheet_content_type"
    t.integer  "spreadsheet_file_size"
    t.datetime "spreadsheet_updated_at"
    t.boolean  "destroy_existing",         default: false
    t.integer  "store_id"
    t.integer  "count_created"
    t.integer  "count_updated"
    t.string   "image_path"
    t.text     "image_labels"
    t.text     "image_file_extensions"
    t.text     "image_types"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",                default: false
  end

  create_table "gemgento_inventories", force: true do |t|
    t.integer  "product_id",                                null: false
    t.integer  "quantity",                  default: 0,     null: false
    t.boolean  "is_in_stock",               default: false, null: false
    t.boolean  "sync_needed",               default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "store_id"
    t.boolean  "use_default_website_stock", default: true
    t.integer  "backorders",                default: 0,     null: false
    t.boolean  "use_config_backorders",     default: true,  null: false
    t.integer  "min_qty",                   default: 0,     null: false
    t.boolean  "use_config_min_qty",        default: true,  null: false
    t.boolean  "manage_stock",              default: true
  end

  add_index "gemgento_inventories", ["product_id", "store_id"], name: "inventories_index", unique: true, using: :btree
  add_index "gemgento_inventories", ["store_id"], name: "inventory_store_index", using: :btree

  create_table "gemgento_inventory_imports", force: true do |t|
    t.string   "spreadsheet_file_name"
    t.string   "spreadsheet_content_type"
    t.integer  "spreadsheet_file_size"
    t.datetime "spreadsheet_updated_at"
    t.text     "import_errors"
    t.boolean  "is_active",                default: true
  end

  create_table "gemgento_line_items", force: true do |t|
    t.integer  "magento_id"
    t.string   "itemizable_type",                                           default: "Gemgento::Order"
    t.integer  "itemizable_id"
    t.integer  "quote_item_id"
    t.integer  "product_id"
    t.string   "product_type"
    t.text     "product_options"
    t.decimal  "weight",                           precision: 12, scale: 4
    t.boolean  "is_virtual"
    t.string   "sku"
    t.string   "name"
    t.string   "applied_rule_ids"
    t.boolean  "free_shipping"
    t.boolean  "is_qty_decimal"
    t.boolean  "no_discount"
    t.decimal  "qty_canceled",                     precision: 12, scale: 4
    t.decimal  "qty_invoiced",                     precision: 12, scale: 4
    t.decimal  "qty_ordered",                      precision: 12, scale: 4
    t.decimal  "qty_refunded",                     precision: 12, scale: 4
    t.decimal  "qty_shipped",                      precision: 12, scale: 4
    t.decimal  "cost",                             precision: 12, scale: 4
    t.decimal  "price",                            precision: 12, scale: 4
    t.decimal  "base_price",                       precision: 12, scale: 4
    t.decimal  "original_price",                   precision: 12, scale: 4
    t.decimal  "base_original_price",              precision: 12, scale: 4
    t.decimal  "tax_percent",                      precision: 12, scale: 4
    t.decimal  "tax_amount",                       precision: 12, scale: 4
    t.decimal  "base_tax_amount",                  precision: 12, scale: 4
    t.decimal  "tax_invoiced",                     precision: 12, scale: 4
    t.decimal  "base_tax_invoiced",                precision: 12, scale: 4
    t.decimal  "discount_percent",                 precision: 12, scale: 4
    t.decimal  "discount_amount",                  precision: 12, scale: 4
    t.decimal  "base_discount_amount",             precision: 12, scale: 4
    t.decimal  "discount_invoiced",                precision: 12, scale: 4
    t.decimal  "base_discount_invoiced",           precision: 12, scale: 4
    t.decimal  "amount_refunded",                  precision: 12, scale: 4
    t.decimal  "base_amount_refunded",             precision: 12, scale: 4
    t.decimal  "row_total",                        precision: 12, scale: 4
    t.decimal  "base_row_total",                   precision: 12, scale: 4
    t.decimal  "row_invoiced",                     precision: 12, scale: 4
    t.decimal  "base_row_invoiced",                precision: 12, scale: 4
    t.decimal  "row_weight",                       precision: 12, scale: 4
    t.string   "gift_message_id"
    t.string   "gift_message"
    t.string   "gift_message_available"
    t.decimal  "base_tax_before_discount",         precision: 12, scale: 4
    t.decimal  "tax_before_discount",              precision: 12, scale: 4
    t.decimal  "weee_tax_applied",                 precision: 12, scale: 4
    t.decimal  "weee_tax_applied_amount",          precision: 12, scale: 4
    t.decimal  "weee_tax_applied_row_amount",      precision: 12, scale: 4
    t.decimal  "base_weee_tax_applied_amount",     precision: 12, scale: 4
    t.decimal  "base_weee_tax_applied_row_amount", precision: 12, scale: 4
    t.decimal  "weee_tax_disposition",             precision: 12, scale: 4
    t.decimal  "weee_tax_row_disposition",         precision: 12, scale: 4
    t.decimal  "base_weee_tax_disposition",        precision: 12, scale: 4
    t.decimal  "base_weee_tax_row_disposition",    precision: 12, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "options"
  end

  add_index "gemgento_line_items", ["itemizable_id"], name: "order_items_index", using: :btree
  add_index "gemgento_line_items", ["itemizable_type", "itemizable_id"], name: "index_gemgento_line_items_on_itemizable_type_and_itemizable_id", using: :btree

  create_table "gemgento_magento_responses", force: true do |t|
    t.text     "request"
    t.text     "body",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "success",                     default: true, null: false
  end

  create_table "gemgento_order_statuses", force: true do |t|
    t.integer  "order_id",                            null: false
    t.integer  "increment_id"
    t.boolean  "is_active",            default: true
    t.integer  "is_customer_notified", default: 1
    t.string   "status"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_order_statuses", ["order_id"], name: "order_statuses_index", using: :btree

  create_table "gemgento_orders", force: true do |t|
    t.integer  "magento_id"
    t.integer  "store_id",                                             null: false
    t.integer  "user_id"
    t.decimal  "tax_amount",                  precision: 12, scale: 4
    t.decimal  "shipping_amount",             precision: 12, scale: 4
    t.decimal  "discount_amount",             precision: 12, scale: 4
    t.decimal  "subtotal",                    precision: 12, scale: 4
    t.decimal  "grand_total",                 precision: 12, scale: 4
    t.decimal  "total_paid",                  precision: 12, scale: 4
    t.decimal  "total_refunded",              precision: 12, scale: 4
    t.decimal  "total_qty_ordered",           precision: 12, scale: 4
    t.decimal  "total_canceled",              precision: 12, scale: 4
    t.decimal  "total_invoiced",              precision: 12, scale: 4
    t.decimal  "total_online_refunded",       precision: 12, scale: 4
    t.decimal  "total_offline_refunded",      precision: 12, scale: 4
    t.decimal  "base_tax_amount",             precision: 12, scale: 4
    t.decimal  "base_shipping_amount",        precision: 12, scale: 4
    t.decimal  "base_discount_amount",        precision: 12, scale: 4
    t.decimal  "base_subtotal",               precision: 12, scale: 4
    t.decimal  "base_grand_total",            precision: 12, scale: 4
    t.decimal  "base_total_paid",             precision: 12, scale: 4
    t.decimal  "base_total_refunded",         precision: 12, scale: 4
    t.decimal  "base_total_qty_ordered",      precision: 12, scale: 4
    t.decimal  "base_total_canceled",         precision: 12, scale: 4
    t.decimal  "base_total_invoiced",         precision: 12, scale: 4
    t.decimal  "base_total_online_refunded",  precision: 12, scale: 4
    t.decimal  "base_total_offline_refunded", precision: 12, scale: 4
    t.integer  "billing_address_id"
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.integer  "shipping_address_id"
    t.string   "shipping_first_name"
    t.string   "shipping_last_name"
    t.string   "billing_name"
    t.string   "shipping_name"
    t.string   "store_to_base_rate"
    t.string   "store_to_order_rate"
    t.string   "base_to_global_rate"
    t.string   "base_to_order_rate"
    t.decimal  "weight",                      precision: 12, scale: 4
    t.string   "store_name"
    t.string   "remote_ip"
    t.string   "status"
    t.string   "state"
    t.string   "applied_rule_ids"
    t.string   "global_currency_code"
    t.string   "base_currency_code"
    t.string   "store_currency_code"
    t.string   "order_currency_code"
    t.string   "shipping_method"
    t.string   "shipping_description"
    t.string   "customer_email"
    t.string   "customer_firstname"
    t.string   "customer_lastname"
    t.boolean  "is_virtual"
    t.integer  "user_group_id"
    t.string   "customer_note_notify"
    t.boolean  "customer_is_guest"
    t.boolean  "email_sent"
    t.string   "increment_id"
    t.string   "gift_message_id"
    t.string   "gift_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "placed_at"
    t.integer  "quote_id"
  end

  add_index "gemgento_orders", ["quote_id"], name: "index_gemgento_orders_on_quote_id", using: :btree

  create_table "gemgento_orders_recurring_profiles", id: false, force: true do |t|
    t.integer "order_id"
    t.integer "recurring_profile_id"
  end

  add_index "gemgento_orders_recurring_profiles", ["order_id", "recurring_profile_id"], name: "order_recurring_profile_index", using: :btree
  add_index "gemgento_orders_recurring_profiles", ["recurring_profile_id"], name: "recurring_profile_index", using: :btree

  create_table "gemgento_pages", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "permalink"
    t.text     "body"
    t.boolean  "show_in_main_nav"
    t.boolean  "is_shop_landing"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_payments", force: true do |t|
    t.integer  "magento_id"
    t.string   "payable_type",                                  default: "Gemgento::Order"
    t.integer  "payable_id",                                                                null: false
    t.integer  "increment_id"
    t.boolean  "is_active",                                     default: true
    t.decimal  "amount_ordered",       precision: 12, scale: 4
    t.decimal  "shipping_amount",      precision: 12, scale: 4
    t.decimal  "base_amount_ordered",  precision: 12, scale: 4
    t.decimal  "base_shipping_amount", precision: 12, scale: 4
    t.string   "method"
    t.string   "po_number"
    t.string   "cc_type"
    t.string   "cc_number_enc"
    t.string   "cc_last4"
    t.string   "cc_owner"
    t.string   "cc_exp_month"
    t.string   "cc_exp_year"
    t.string   "cc_ss_start_month"
    t.string   "cc_ss_start_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_payments", ["payable_id"], name: "order_payments_index", using: :btree
  add_index "gemgento_payments", ["payable_type", "payable_id"], name: "index_gemgento_payments_on_payable_type_and_payable_id", using: :btree

  create_table "gemgento_price_rules", force: true do |t|
    t.integer  "magento_id"
    t.string   "name"
    t.text     "description"
    t.datetime "from_date"
    t.datetime "to_date"
    t.boolean  "is_active",                                      default: false, null: false
    t.boolean  "stop_rules_processing",                          default: true,  null: false
    t.integer  "sort_order"
    t.string   "simple_action"
    t.decimal  "discount_amount",       precision: 10, scale: 0
    t.boolean  "sub_is_enable",                                  default: false, null: false
    t.string   "sub_simple_action"
    t.decimal  "sub_discount_amount",   precision: 10, scale: 0
    t.text     "conditions"
  end

  create_table "gemgento_price_rules_stores", id: false, force: true do |t|
    t.integer "price_rule_id"
    t.integer "store_id"
  end

  add_index "gemgento_price_rules_stores", ["price_rule_id", "store_id"], name: "index_gemgento_price_rules_stores_on_price_rule_id_and_store_id", using: :btree
  add_index "gemgento_price_rules_stores", ["store_id"], name: "index_gemgento_price_rules_stores_on_store_id", using: :btree

  create_table "gemgento_price_rules_user_groups", force: true do |t|
    t.integer "price_rule_id"
    t.integer "user_group_id"
  end

  add_index "gemgento_price_rules_user_groups", ["price_rule_id", "user_group_id"], name: "price_rule_user_group_index", using: :btree
  add_index "gemgento_price_rules_user_groups", ["user_group_id"], name: "user_group_index", using: :btree

  create_table "gemgento_product_attribute_options", force: true do |t|
    t.integer  "product_attribute_id"
    t.string   "label"
    t.string   "value"
    t.boolean  "sync_needed",          default: true, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "order"
    t.integer  "store_id"
  end

  add_index "gemgento_product_attribute_options", ["product_attribute_id", "store_id"], name: "attribute_options_index", using: :btree
  add_index "gemgento_product_attribute_options", ["store_id"], name: "product_attribute_option_store_index", using: :btree

  create_table "gemgento_product_attribute_sets", force: true do |t|
    t.integer  "magento_id"
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "sync_needed", default: true, null: false
    t.datetime "deleted_at"
  end

  create_table "gemgento_product_attribute_values", force: true do |t|
    t.integer  "product_id"
    t.integer  "product_attribute_id"
    t.text     "value"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "store_id"
  end

  add_index "gemgento_product_attribute_values", ["product_attribute_id"], name: "product_attribute_values_product_attribute_index", using: :btree
  add_index "gemgento_product_attribute_values", ["product_id"], name: "product_attribute_values_index", using: :btree

  create_table "gemgento_product_attributes", force: true do |t|
    t.integer  "magento_id"
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
    t.text     "default_value"
    t.datetime "deleted_at"
  end

  create_table "gemgento_product_categories", force: true do |t|
    t.integer  "category_id"
    t.integer  "product_id"
    t.integer  "position",    default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "store_id"
    t.boolean  "sync_needed", default: false
  end

  add_index "gemgento_product_categories", ["category_id"], name: "product_categories_category_index", using: :btree
  add_index "gemgento_product_categories", ["product_id"], name: "product_categories_product_index", using: :btree

  create_table "gemgento_product_imports", force: true do |t|
    t.text     "import_errors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "spreadsheet_file_name"
    t.string   "spreadsheet_content_type"
    t.integer  "spreadsheet_file_size"
    t.datetime "spreadsheet_updated_at"
    t.boolean  "include_images"
    t.string   "image_path"
    t.text     "image_labels"
    t.integer  "store_id"
    t.integer  "root_category_id"
    t.integer  "product_attribute_set_id"
    t.integer  "count_created"
    t.integer  "count_updated"
    t.integer  "simple_product_visibility"
    t.integer  "configurable_product_visibility"
    t.text     "image_file_extensions"
    t.text     "image_types"
  end

  create_table "gemgento_product_imports_configurable_attributes", id: false, force: true do |t|
    t.integer "product_import_id",    default: 0, null: false
    t.integer "product_attribute_id", default: 0, null: false
  end

  create_table "gemgento_products", force: true do |t|
    t.integer  "magento_id"
    t.string   "magento_type"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "sku"
    t.string   "product_attribute_set_id"
    t.boolean  "sync_needed",              default: true, null: false
    t.boolean  "status",                   default: true
    t.integer  "visibility",               default: 4
    t.datetime "deleted_at"
    t.integer  "swatch_id"
    t.datetime "cache_expires_at"
  end

  create_table "gemgento_products_tags", id: false, force: true do |t|
    t.integer "product_id"
    t.integer "tag_id"
  end

  add_index "gemgento_products_tags", ["product_id", "tag_id"], name: "index_gemgento_products_tags_on_product_id_and_tag_id", using: :btree
  add_index "gemgento_products_tags", ["tag_id"], name: "index_gemgento_products_tags_on_tag_id", using: :btree

  create_table "gemgento_quotes", force: true do |t|
    t.integer  "magento_id"
    t.integer  "store_id"
    t.integer  "user_id"
    t.integer  "user_group_id"
    t.datetime "converted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",                                                  default: true
    t.boolean  "is_virtual",                                                 default: false
    t.boolean  "is_multi_shipping",                                          default: false
    t.string   "original_order_id"
    t.decimal  "store_to_base_rate",                precision: 12, scale: 4, default: 1.0
    t.decimal  "store_to_quote_rate",               precision: 12, scale: 4, default: 1.0
    t.string   "base_currency_code"
    t.string   "store_currency_code"
    t.string   "quote_currency_code"
    t.decimal  "grand_total",                       precision: 12, scale: 4
    t.decimal  "base_grand_total",                  precision: 12, scale: 4
    t.string   "checkout_method"
    t.string   "customer_email"
    t.string   "customer_prefix"
    t.string   "customer_first_name"
    t.string   "customer_middle_name"
    t.string   "customer_last_name"
    t.string   "customer_suffix"
    t.text     "customer_note"
    t.boolean  "customer_note_notify",                                       default: false
    t.boolean  "customer_is_guest",                                          default: false
    t.string   "applied_rule_ids"
    t.string   "reserved_order_id"
    t.string   "password_hash"
    t.string   "coupon_code"
    t.string   "global_currency_code"
    t.decimal  "base_to_global_rate",               precision: 12, scale: 4, default: 1.0
    t.decimal  "base_to_order_rate",                precision: 12, scale: 4, default: 1.0
    t.string   "customer_taxvat"
    t.string   "customer_gender"
    t.decimal  "subtotal",                          precision: 12, scale: 4
    t.decimal  "base_subtotal",                     precision: 12, scale: 4
    t.decimal  "base_subtotal_with_discount",       precision: 12, scale: 4
    t.string   "shipping_method"
    t.text     "ext_shipping_info"
    t.decimal  "shipping_amount",                   precision: 12, scale: 4
    t.integer  "gift_message_id"
    t.text     "gift_message"
    t.decimal  "customer_balance_amount_used",      precision: 12, scale: 4
    t.decimal  "base_customer_balance_amount_used", precision: 12, scale: 4
    t.boolean  "use_customer_balance",                                       default: false
    t.decimal  "gift_cards_amount",                 precision: 12, scale: 4
    t.decimal  "base_gift_cards_amount",            precision: 12, scale: 4
    t.boolean  "use_reward_points",                                          default: false
    t.decimal  "reward_points_balance",             precision: 12, scale: 4
    t.decimal  "reward_currency_amount",            precision: 12, scale: 4
    t.decimal  "base_reward_currency_amount",       precision: 12, scale: 4
  end

  create_table "gemgento_recurring_profiles", force: true do |t|
    t.integer  "magento_id"
    t.string   "state"
    t.integer  "user_id"
    t.integer  "store_id"
    t.string   "method_code"
    t.integer  "reference_id"
    t.string   "subscriber_name"
    t.datetime "start_datetime"
    t.string   "internal_reference_id"
    t.string   "schedule_description"
    t.string   "period_unit"
    t.integer  "period_frequency"
    t.decimal  "billing_amount",        precision: 8, scale: 2
    t.string   "currency_code"
    t.decimal  "shipping_amount",       precision: 8, scale: 2
    t.decimal  "tax_amount",            precision: 8, scale: 2
    t.text     "order_info"
    t.text     "order_item_info"
    t.text     "billing_address_info"
    t.text     "shipping_address_info"
    t.text     "profile_vendor_info"
    t.text     "additional_info"
  end

  add_index "gemgento_recurring_profiles", ["store_id"], name: "index_gemgento_recurring_profiles_on_store_id", using: :btree
  add_index "gemgento_recurring_profiles", ["user_id"], name: "index_gemgento_recurring_profiles_on_user_id", using: :btree

  create_table "gemgento_regions", force: true do |t|
    t.integer  "magento_id", null: false
    t.string   "code"
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_relation_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "applies_to"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "gemgento_relations", force: true do |t|
    t.integer  "relation_type_id"
    t.integer  "relatable_id"
    t.string   "relatable_type"
    t.integer  "related_to_id"
    t.string   "related_to_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "gemgento_saved_credit_cards", force: true do |t|
    t.integer  "magento_id"
    t.integer  "user_id"
    t.string   "token"
    t.string   "cc_number"
    t.integer  "exp_month"
    t.integer  "exp_year"
    t.string   "cc_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_sessions", force: true do |t|
    t.string   "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_shipment_comments", force: true do |t|
    t.integer  "shipment_id"
    t.text     "comment"
    t.boolean  "is_customer_notified"
    t.integer  "magento_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_shipment_items", force: true do |t|
    t.integer "shipment_id"
    t.string  "sku"
    t.string  "name"
    t.integer "order_item_id"
    t.integer "product_id"
    t.float   "weight",        limit: 24
    t.float   "price",         limit: 24
    t.float   "qty",           limit: 24
    t.integer "magento_id"
    t.decimal "quantity",                 precision: 10, scale: 0, default: 0, null: false
  end

  add_index "gemgento_shipment_items", ["shipment_id"], name: "shipment_items_shipment_id", using: :btree

  create_table "gemgento_shipment_tracks", force: true do |t|
    t.integer "shipment_id"
    t.string  "carrier_code"
    t.string  "title"
    t.string  "number"
    t.integer "order_id"
    t.integer "magento_id"
  end

  add_index "gemgento_shipment_tracks", ["shipment_id"], name: "shipment_tracks_shipment_index", using: :btree

  create_table "gemgento_shipments", force: true do |t|
    t.integer  "magento_id"
    t.integer  "order_id"
    t.string   "increment_id"
    t.integer  "store_id"
    t.integer  "shipping_address_id"
    t.float    "total_qty",           limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_shipments", ["order_id"], name: "shipments_order_index", using: :btree

  create_table "gemgento_shopify_adapters", force: true do |t|
    t.integer  "gemgento_model_id"
    t.string   "gemgento_model_type"
    t.string   "shopify_model_type"
    t.integer  "shopify_model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_shopify_adapters", ["gemgento_model_id", "gemgento_model_type"], name: "gemgento_model_index", using: :btree
  add_index "gemgento_shopify_adapters", ["shopify_model_id", "shopify_model_type"], name: "shopify_model_index", using: :btree

  create_table "gemgento_stock_notifications", force: true do |t|
    t.integer  "product_id"
    t.string   "product_name"
    t.string   "product_url"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_store_tags", force: true do |t|
    t.integer "store_id"
    t.integer "tag_id"
    t.integer "base_popularity", default: 0
  end

  add_index "gemgento_store_tags", ["store_id"], name: "index_gemgento_store_tags_on_store_id", using: :btree
  add_index "gemgento_store_tags", ["tag_id"], name: "index_gemgento_store_tags_on_tag_id", using: :btree

  create_table "gemgento_stores", force: true do |t|
    t.integer  "magento_id",                    null: false
    t.string   "code"
    t.integer  "group_id"
    t.string   "name"
    t.integer  "sort_order"
    t.boolean  "is_active",     default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id"
    t.string   "currency_code", default: "usd"
  end

  add_index "gemgento_stores", ["magento_id"], name: "index_gemgento_stores_on_magento_id", unique: true, using: :btree

  create_table "gemgento_stores_products", force: true do |t|
    t.integer "product_id"
    t.integer "store_id"
  end

  add_index "gemgento_stores_products", ["product_id", "store_id"], name: "stores_products_index", unique: true, using: :btree
  add_index "gemgento_stores_products", ["store_id"], name: "store_product_store_index", using: :btree

  create_table "gemgento_stores_users", force: true do |t|
    t.integer "store_id"
    t.integer "user_id"
  end

  create_table "gemgento_subscribers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "country_id"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_swatches", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "gemgento_syncs", force: true do |t|
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_complete", default: false
  end

  create_table "gemgento_tags", force: true do |t|
    t.integer "magento_id"
    t.string  "name"
    t.string  "status",      default: "0"
    t.boolean "sync_needed", default: false
  end

  create_table "gemgento_user_groups", force: true do |t|
    t.integer  "magento_id"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_users", force: true do |t|
    t.integer  "magento_id"
    t.string   "created_in"
    t.string   "email",                  default: "",   null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.integer  "user_group_id"
    t.string   "prefix"
    t.string   "suffix"
    t.date     "dob"
    t.string   "taxvat"
    t.boolean  "confirmation"
    t.string   "magento_password"
    t.boolean  "sync_needed",            default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "increment_id"
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "unencrypted_password"
    t.string   "type"
    t.string   "gender"
    t.datetime "deleted_at"
  end

  add_index "gemgento_users", ["email", "deleted_at"], name: "users_email_deleted_index", unique: true, using: :btree
  add_index "gemgento_users", ["magento_id"], name: "index_gemgento_users_on_magento_id", unique: true, using: :btree
  add_index "gemgento_users", ["reset_password_token"], name: "index_gemgento_users_on_reset_password_token", unique: true, using: :btree

end
