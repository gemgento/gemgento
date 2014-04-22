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

ActiveRecord::Schema.define(version: 20140422140433) do

  create_table "gemegento_shipment_items", force: true do |t|
    t.integer "shipment_id"
    t.string "sku"
    t.string "name"
    t.integer "order_item_id"
    t.integer "product_id"
    t.float "weight"
    t.float "price"
    t.float "qty"
    t.integer "magento_id"
  end

  add_index "gemegento_shipment_items", ["shipment_id"], name: "index_gemegento_shipment_items_on_shipment_id", using: :btree

  create_table "gemgento_addresses", force: true do |t|
    t.integer "user_address_id"
    t.integer "user_id"
    t.string "increment_id"
    t.string "city"
    t.string "company"
    t.integer "country_id"
    t.string "fax"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
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
    t.boolean "is_default_billing", default: false
    t.boolean "is_default_shipping", default: false
  end

  create_table "gemgento_api_jobs", force: true do |t|
    t.integer "source_id"
    t.string "kind"
    t.string "state"
    t.string "source_type"
    t.string "request_url"
    t.text "request", limit: 2147483647
    t.text "response", limit: 2147483647
    t.boolean "locked"
    t.text "request_body", limit: 2147483647
    t.string "request_status"
    t.string "response_status"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_asset_files", force: true do |t|
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
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
    t.integer "store_id"
    t.integer "asset_file_id"
  end

  add_index "gemgento_assets", ["product_id"], name: "index_gemgento_assets_on_product_id", using: :btree
  add_index "gemgento_assets", ["store_id"], name: "index_gemgento_assets_on_store_id", using: :btree

  create_table "gemgento_assets_asset_types", id: false, force: true do |t|
    t.integer "asset_id", default: 0, null: false
    t.integer "asset_type_id", default: 0, null: false
  end

  create_table "gemgento_attribute_set_attributes", id: false, force: true do |t|
    t.integer "product_attribute_set_id", default: 0, null: false
    t.integer "product_attribute_id", default: 0, null: false
  end

  add_index "gemgento_attribute_set_attributes", ["product_attribute_id"], name: "index_gemgento_attribute_set_attributes_on_product_attribute_id", using: :btree
  add_index "gemgento_attribute_set_attributes", ["product_attribute_set_id", "product_attribute_id"], name: "attribute_set_attributes_index", unique: true, using: :btree

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
    t.integer "children_count"
    t.boolean "sync_needed", default: true, null: false
    t.boolean "include_in_menu", default: true, null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "deleted_at"
  end

  add_index "gemgento_categories", ["magento_id"], name: "index_gemgento_categories_on_magento_id", unique: true, using: :btree

  create_table "gemgento_categories_stores", force: true do |t|
    t.integer "category_id"
    t.integer "store_id"
  end

  add_index "gemgento_categories_stores", ["category_id", "store_id"], name: "index_gemgento_categories_stores_on_category_id_and_store_id", unique: true, using: :btree
  add_index "gemgento_categories_stores", ["store_id"], name: "index_gemgento_categories_stores_on_store_id", using: :btree

  create_table "gemgento_configurable_attributes", id: false, force: true do |t|
    t.integer "product_id", default: 0, null: false
    t.integer "product_attribute_id", default: 0, null: false
  end

  add_index "gemgento_configurable_attributes", ["product_attribute_id"], name: "index_gemgento_configurable_attributes_on_product_attribute_id", using: :btree
  add_index "gemgento_configurable_attributes", ["product_id", "product_attribute_id"], name: "configurable_attribute_index", unique: true, using: :btree

  create_table "gemgento_configurable_simple_relations", id: false, force: true do |t|
    t.integer "configurable_product_id", default: 0, null: false
    t.integer "simple_product_id", default: 0, null: false
  end

  add_index "gemgento_configurable_simple_relations", ["configurable_product_id", "simple_product_id"], name: "configurable_simple_index", unique: true, using: :btree

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
    t.integer "store_id"
    t.boolean "use_default_website_stock", default: true
  end

  add_index "gemgento_inventories", ["product_id", "store_id"], name: "index_gemgento_inventories_on_product_id_and_store_id", unique: true, using: :btree
  add_index "gemgento_inventories", ["store_id"], name: "index_gemgento_inventories_on_store_id", using: :btree

  create_table "gemgento_magento_responses", force: true do |t|
    t.text "request"
    t.text "body", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "success", default: true, null: false
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

  add_index "gemgento_order_items", ["order_id"], name: "index_gemgento_order_items_on_order_id", using: :btree

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
    t.string "cc_exp_month"
    t.string "cc_exp_year"
    t.string "cc_ss_start_month"
    t.string "cc_ss_start_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_order_payments", ["order_id"], name: "index_gemgento_order_payments_on_order_id", using: :btree

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

  add_index "gemgento_order_statuses", ["order_id"], name: "index_gemgento_order_statuses_on_order_id", using: :btree

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
    t.string "billing_first_name"
    t.string "billing_last_name"
    t.integer "shipping_address_id"
    t.string "shipping_first_name"
    t.string "shipping_last_name"
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
    t.datetime "placed_at"
  end

  create_table "gemgento_product_attribute_options", force: true do |t|
    t.integer "product_attribute_id"
    t.string "label"
    t.string "value"
    t.boolean "sync_needed", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.integer "store_id"
  end

  add_index "gemgento_product_attribute_options", ["product_attribute_id", "store_id"], name: "attribute_options_index", using: :btree
  add_index "gemgento_product_attribute_options", ["store_id"], name: "index_gemgento_product_attribute_options_on_store_id", using: :btree

  create_table "gemgento_product_attribute_sets", force: true do |t|
    t.integer "magento_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sync_needed", default: true, null: false
    t.datetime "deleted_at"
  end

  create_table "gemgento_product_attribute_values", force: true do |t|
    t.integer "product_id"
    t.integer "product_attribute_id"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "store_id"
  end

  add_index "gemgento_product_attribute_values", ["product_attribute_id"], name: "index_gemgento_product_attribute_values_on_product_attribute_id", using: :btree
  add_index "gemgento_product_attribute_values", ["product_id"], name: "index_gemgento_product_attribute_values_on_product_id", using: :btree

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
    t.datetime "deleted_at"
  end

  create_table "gemgento_product_categories", force: true do |t|
    t.integer "category_id"
    t.integer "product_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "store_id"
    t.boolean "sync_needed", default: false
  end

  add_index "gemgento_product_categories", ["category_id"], name: "index_gemgento_product_categories_on_category_id", using: :btree
  add_index "gemgento_product_categories", ["product_id"], name: "index_gemgento_product_categories_on_product_id", using: :btree

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
    t.text "image_labels"
    t.integer "store_id"
    t.integer "root_category_id"
    t.integer "product_attribute_set_id"
    t.integer "count_created"
    t.integer "count_updated"
    t.integer "simple_product_visibility"
    t.integer "configurable_product_visibility"
    t.text "image_file_extensions"
    t.text "image_types"
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
    t.boolean "sync_needed", default: true, null: false
    t.boolean "status", default: true
    t.integer "visibility", default: 4
    t.datetime "deleted_at"
    t.integer "swatch_id"
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

  create_table "gemgento_saved_credit_cards", force: true do |t|
    t.integer "magento_id"
    t.integer "user_id"
    t.string "token"
    t.string "cc_number"
    t.integer "exp_month"
    t.integer "exp_year"
    t.string "cc_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_sessions", force: true do |t|
    t.string "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gemgento_shipment_comments", force: true do |t|
    t.integer "shipment_id"
    t.text "comment"
    t.boolean "is_customer_notified"
    t.integer "magento_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gemgento_shipment_tracks", force: true do |t|
    t.integer "shipment_id"
    t.string "carrier_code"
    t.string "title"
    t.string "number"
    t.integer "order_id"
    t.integer "magento_id"
  end

  add_index "gemgento_shipment_tracks", ["shipment_id"], name: "index_gemgento_shipment_tracks_on_shipment_id", using: :btree

  create_table "gemgento_shipments", force: true do |t|
    t.integer "magento_id"
    t.integer "order_id"
    t.string "increment_id"
    t.integer "store_id"
    t.integer "shipping_address_id"
    t.float "total_qty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gemgento_shipments", ["order_id"], name: "index_gemgento_shipments_on_order_id", using: :btree

  create_table "gemgento_stores", force: true do |t|
    t.integer "magento_id", null: false
    t.string "code"
    t.integer "group_id"
    t.string "name"
    t.integer "sort_order"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "website_id"
    t.string "currency_code", default: "usd"
  end

  add_index "gemgento_stores", ["magento_id"], name: "index_gemgento_stores_on_magento_id", unique: true, using: :btree

  create_table "gemgento_stores_products", force: true do |t|
    t.integer "product_id"
    t.integer "store_id"
  end

  add_index "gemgento_stores_products", ["product_id", "store_id"], name: "stores_products_index", unique: true, using: :btree
  add_index "gemgento_stores_products", ["store_id"], name: "index_gemgento_stores_products_on_store_id", using: :btree

  create_table "gemgento_stores_users", force: true do |t|
    t.integer "store_id"
    t.integer "user_id"
  end

  create_table "gemgento_subscribers", force: true do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "country_id"
    t.string "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string "created_in"
    t.string "email", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
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
    t.string "gender"
    t.datetime "deleted_at"
  end

  add_index "gemgento_users", ["email", "deleted_at"], name: "index_gemgento_users_on_email_and_deleted_at", unique: true, using: :btree
  add_index "gemgento_users", ["magento_id"], name: "index_gemgento_users_on_magento_id", unique: true, using: :btree
  add_index "gemgento_users", ["reset_password_token"], name: "index_gemgento_users_on_reset_password_token", unique: true, using: :btree

end
