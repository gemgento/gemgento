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

ActiveRecord::Schema.define(version: 20130930183059) do

  create_table "active_admin_comments", force: true do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "gemgento_addresses", force: true do |t|
    t.integer "user_address_id"
    t.integer "user_id"
    t.string "increment_id"
    t.string "city"
    t.string "company"
    t.integer "country_id"
    t.string "fax"
    t.string "fname"
    t.string "mname"
    t.string "lname"
    t.string "postcode"
    t.string "prefix"
    t.string "suffix"
    t.string "region_name"
    t.integer "region_id"
    t.string "street"
    t.string "telephone"
    t.string "address_type"
    t.boolean "sync_needed", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "order_address_id"
    t.integer "order_id"
    t.boolean "is_default", default: false
  end

  create_table "gemgento_asset_types", force: true do |t|
    t.integer "product_attribute_set_id"
    t.string "code"
    t.string "scope"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_assets", force: true do |t|
    t.integer "product_id"
    t.string "url"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file"
    t.string "label"
    t.boolean "sync_needed", default: true, null: false
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "gemgento_assets_asset_types", id: false, force: true do |t|
    t.integer "asset_id", default: 0, null: false
    t.integer "asset_type_id", default: 0, null: false
  end

  create_table "gemgento_attribute_set_attributes", id: false, force: true do |t|
    t.integer "product_attribute_set_id", default: 0, null: false
    t.integer "product_attribute_id", default: 0, null: false
  end

  create_table "gemgento_categories", force: true do |t|
    t.integer "magento_id"
    t.string "name"
    t.string "url_key"
    t.integer "parent_id"
    t.integer "position"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "all_children"
    t.string "children"
    t.integer "children_count"
    t.boolean "sync_needed", default: true, null: false
    t.boolean "include_in_menu", default: true, null: false
  end

  add_index "gemgento_categories", ["magento_id"], name: "index_gemgento_categories_on_magento_id", unique: true, using: :btree

  create_table "gemgento_categories_products", id: false, force: true do |t|
    t.integer "product_id", default: 0, null: false
    t.integer "category_id", default: 0, null: false
  end

  create_table "gemgento_configurable_attributes", id: false, force: true do |t|
    t.integer "product_id", default: 0, null: false
    t.integer "product_attribute_id", default: 0, null: false
  end

  create_table "gemgento_configurable_simple_relations", id: false, force: true do |t|
    t.integer "configurable_product_id", default: 0, null: false
    t.integer "simple_product_id", default: 0, null: false
  end

  create_table "gemgento_countries", force: true do |t|
    t.string "magento_id", null: false
    t.string "iso2_code"
    t.string "iso3_code"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_gift_messages", force: true do |t|
    t.integer "magento_id"
    t.string "to"
    t.string "from"
    t.text "message"
  end

  create_table "gemgento_inventories", force: true do |t|
    t.integer "product_id", null: false
    t.integer "quantity", default: 0, null: false
    t.boolean "is_in_stock", default: false, null: false
    t.boolean "sync_needed", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_magento_responses", force: true do |t|
    t.text "request"
    t.text "body", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "success", default: true, null: false
  end

  create_table "gemgento_order_addresses", force: true do |t|
    t.integer "order_id", null: false
    t.integer "increment_id"
    t.boolean "is_active", default: true, null: false
    t.string "address_type"
    t.string "fname"
    t.string "lname"
    t.string "company_name"
    t.string "street"
    t.string "city"
    t.string "region_name"
    t.integer "region_id"
    t.string "postcode"
    t.integer "country_id"
    t.string "telephone"
    t.string "fax"
    t.integer "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_order_items", force: true do |t|
    t.integer "magento_id"
    t.integer "order_id"
    t.integer "quote_item_id"
    t.integer "product_id"
    t.string "product_type"
    t.text "product_options"
    t.decimal "weight", precision: 12, scale: 4
    t.boolean "is_virtual"
    t.string "sku"
    t.string "name"
    t.string "applied_rule_ids"
    t.boolean "free_shipping"
    t.boolean "is_qty_decimal"
    t.boolean "no_discount"
    t.decimal "qty_canceled", precision: 12, scale: 4
    t.decimal "qty_invoiced", precision: 12, scale: 4
    t.decimal "qty_ordered", precision: 12, scale: 4
    t.decimal "qty_refunded", precision: 12, scale: 4
    t.decimal "qty_shipped", precision: 12, scale: 4
    t.decimal "cost", precision: 12, scale: 4
    t.decimal "price", precision: 12, scale: 4
    t.decimal "base_price", precision: 12, scale: 4
    t.decimal "original_price", precision: 12, scale: 4
    t.decimal "base_original_price", precision: 12, scale: 4
    t.decimal "tax_percent", precision: 12, scale: 4
    t.decimal "tax_amount", precision: 12, scale: 4
    t.decimal "base_tax_amount", precision: 12, scale: 4
    t.decimal "tax_invoiced", precision: 12, scale: 4
    t.decimal "base_tax_invoiced", precision: 12, scale: 4
    t.decimal "discount_percent", precision: 12, scale: 4
    t.decimal "discount_amount", precision: 12, scale: 4
    t.decimal "base_discount_amount", precision: 12, scale: 4
    t.decimal "discount_invoiced", precision: 12, scale: 4
    t.decimal "base_discount_invoiced", precision: 12, scale: 4
    t.decimal "amount_refunded", precision: 12, scale: 4
    t.decimal "base_amount_refunded", precision: 12, scale: 4
    t.decimal "row_total", precision: 12, scale: 4
    t.decimal "base_row_total", precision: 12, scale: 4
    t.decimal "row_invoiced", precision: 12, scale: 4
    t.decimal "base_row_invoiced", precision: 12, scale: 4
    t.decimal "row_weight", precision: 12, scale: 4
    t.string "gift_message_id"
    t.string "gift_message"
    t.string "gift_message_available"
    t.decimal "base_tax_before_discount", precision: 12, scale: 4
    t.decimal "tax_before_discount", precision: 12, scale: 4
    t.decimal "weee_tax_applied", precision: 12, scale: 4
    t.decimal "weee_tax_applied_amount", precision: 12, scale: 4
    t.decimal "weee_tax_applied_row_amount", precision: 12, scale: 4
    t.decimal "base_weee_tax_applied_amount", precision: 12, scale: 4
    t.decimal "base_weee_tax_applied_row_amount", precision: 12, scale: 4
    t.decimal "weee_tax_disposition", precision: 12, scale: 4
    t.decimal "weee_tax_row_disposition", precision: 12, scale: 4
    t.decimal "base_weee_tax_disposition", precision: 12, scale: 4
    t.decimal "base_weee_tax_row_disposition", precision: 12, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_order_payments", force: true do |t|
    t.integer "magento_id"
    t.integer "order_id", null: false
    t.integer "increment_id"
    t.boolean "is_active", default: true
    t.decimal "amount_ordered", precision: 12, scale: 4
    t.decimal "shipping_amount", precision: 12, scale: 4
    t.decimal "base_amount_ordered", precision: 12, scale: 4
    t.decimal "base_shipping_amount", precision: 12, scale: 4
    t.string "method"
    t.string "po_number"
    t.string "cc_type"
    t.string "cc_number_enc"
    t.string "cc_last4"
    t.string "cc_owner"
    t.integer "cc_exp_month"
    t.integer "cc_exp_year"
    t.integer "cc_ss_start_month"
    t.integer "cc_ss_start_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_order_statuses", force: true do |t|
    t.integer "order_id", null: false
    t.integer "increment_id"
    t.boolean "is_active", default: true
    t.integer "is_customer_notified", default: 1
    t.string "status"
    t.string "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_orders", force: true do |t|
    t.integer "order_id"
    t.integer "store_id", null: false
    t.boolean "is_active"
    t.integer "user_id"
    t.decimal "tax_amount", precision: 12, scale: 4
    t.decimal "shipping_amount", precision: 12, scale: 4
    t.decimal "discount_amount", precision: 12, scale: 4
    t.decimal "subtotal", precision: 12, scale: 4
    t.decimal "grand_total", precision: 12, scale: 4
    t.decimal "total_paid", precision: 12, scale: 4
    t.decimal "total_refunded", precision: 12, scale: 4
    t.decimal "total_qty_ordered", precision: 12, scale: 4
    t.decimal "total_canceled", precision: 12, scale: 4
    t.decimal "total_invoiced", precision: 12, scale: 4
    t.decimal "total_online_refunded", precision: 12, scale: 4
    t.decimal "total_offline_refunded", precision: 12, scale: 4
    t.decimal "base_tax_amount", precision: 12, scale: 4
    t.decimal "base_shipping_amount", precision: 12, scale: 4
    t.decimal "base_discount_amount", precision: 12, scale: 4
    t.decimal "base_subtotal", precision: 12, scale: 4
    t.decimal "base_grand_total", precision: 12, scale: 4
    t.decimal "base_total_paid", precision: 12, scale: 4
    t.decimal "base_total_refunded", precision: 12, scale: 4
    t.decimal "base_total_qty_ordered", precision: 12, scale: 4
    t.decimal "base_total_canceled", precision: 12, scale: 4
    t.decimal "base_total_invoiced", precision: 12, scale: 4
    t.decimal "base_total_online_refunded", precision: 12, scale: 4
    t.decimal "base_total_offline_refunded", precision: 12, scale: 4
    t.integer "billing_address_id"
    t.string "billing_fname"
    t.string "billing_lname"
    t.integer "shipping_address_id"
    t.string "shipping_fname"
    t.string "shipping_lname"
    t.string "billing_name"
    t.string "shipping_name"
    t.string "store_to_base_rate"
    t.string "store_to_order_rate"
    t.string "base_to_global_rate"
    t.string "base_to_order_rate"
    t.decimal "weight", precision: 12, scale: 4
    t.string "store_name"
    t.string "remote_ip"
    t.string "status"
    t.string "state"
    t.string "applied_rule_ids"
    t.string "global_currency_code"
    t.string "base_currency_code"
    t.string "store_currency_code"
    t.string "order_currency_code"
    t.string "shipping_method"
    t.string "shipping_description"
    t.string "customer_email"
    t.string "customer_firstname"
    t.string "customer_lastname"
    t.string "magento_quote_id"
    t.boolean "is_virtual"
    t.integer "user_group_id"
    t.string "customer_note_notify"
    t.boolean "customer_is_guest"
    t.boolean "email_sent"
    t.string "increment_id"
    t.string "gift_message_id"
    t.string "gift_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_product_attribute_options", force: true do |t|
    t.integer "product_attribute_id"
    t.string "label"
    t.string "value"
    t.boolean "sync_needed", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_product_attribute_sets", force: true do |t|
    t.integer "magento_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sync_needed", default: true, null: false
  end

  create_table "gemgento_product_attribute_values", force: true do |t|
    t.integer "product_id"
    t.integer "product_attribute_id"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_product_attributes", force: true do |t|
    t.integer "magento_id"
    t.string "code"
    t.string "frontend_input"
    t.string "scope"
    t.boolean "is_unique"
    t.boolean "is_required"
    t.boolean "is_configurable"
    t.boolean "is_searchable"
    t.boolean "is_visible_in_advanced_search"
    t.boolean "is_comparable"
    t.boolean "is_used_for_promo_rules"
    t.boolean "is_visible_on_front"
    t.boolean "used_in_product_listing"
    t.boolean "sync_needed", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "default_value"
  end

  create_table "gemgento_product_imports", force: true do |t|
    t.text "import_errors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "spreadsheet_file_name"
    t.string "spreadsheet_content_type"
    t.integer "spreadsheet_file_size"
    t.datetime "spreadsheet_updated_at"
    t.boolean "include_images"
    t.string "image_path"
    t.string "image_file_extension"
    t.text "image_labels"
    t.integer "store_id"
    t.integer "root_category_id"
    t.integer "product_attribute_set_id"
    t.integer "count_created"
    t.integer "count_updated"
    t.integer "simple_product_visibility"
    t.integer "configurable_product_visibility"
  end

  create_table "gemgento_product_imports_configurable_attributes", id: false, force: true do |t|
    t.integer "product_import_id", default: 0, null: false
    t.integer "product_attribute_id", default: 0, null: false
  end

  create_table "gemgento_products", force: true do |t|
    t.integer "magento_id"
    t.string "magento_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sku"
    t.string "product_attribute_set_id"
    t.string "store_id"
    t.boolean "sync_needed", default: true, null: false
    t.boolean "status", default: true
    t.integer "visibility", default: 4
    t.datetime "deleted_at"
    t.integer "order"
  end

  create_table "gemgento_regions", force: true do |t|
    t.integer "magento_id", null: false
    t.string "code"
    t.string "name"
    t.integer "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_relation_types", force: true do |t|
    t.string "name"
    t.text "description"
    t.string "applies_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_relations", force: true do |t|
    t.integer "relation_type_id"
    t.integer "relatable_id"
    t.string "relatable_type"
    t.integer "related_to_id"
    t.string "related_to_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_sessions", force: true do |t|
    t.string "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_stores", force: true do |t|
    t.integer "magento_id", null: false
    t.string "code"
    t.integer "group_id"
    t.string "name"
    t.integer "sort_order"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_stores", ["magento_id"], name: "index_gemgento_stores_on_magento_id", unique: true, using: :btree

  create_table "gemgento_swatches", force: true do |t|
    t.string "name"
    t.string "description"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "gemgento_syncs", force: true do |t|
    t.string "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_complete", default: false
  end

  create_table "gemgento_user_groups", force: true do |t|
    t.integer "magento_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_users", force: true do |t|
    t.integer "magento_id"
    t.integer "store_id"
    t.string "created_in"
    t.string "email", default: "", null: false
    t.string "fname"
    t.string "lname"
    t.string "mname"
    t.integer "user_group_id"
    t.string "prefix"
    t.string "suffix"
    t.date "dob"
    t.string "taxvat"
    t.boolean "confirmation"
    t.string "magento_password"
    t.boolean "sync_needed", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "increment_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "unencrypted_password"
    t.string "type"
  end

  add_index "gemgento_users", ["email"], name: "index_gemgento_users_on_email", unique: true, using: :btree
  add_index "gemgento_users", ["magento_id"], name: "index_gemgento_users_on_magento_id", unique: true, using: :btree
  add_index "gemgento_users", ["reset_password_token"], name: "index_gemgento_users_on_reset_password_token", unique: true, using: :btree

end
