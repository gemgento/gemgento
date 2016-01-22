class Gemgento2 < ActiveRecord::Migration
  def change

    create_table "active_admin_comments", force: :cascade do |t|
      t.string   "namespace",     limit: 255
      t.text     "body",          limit: 65535
      t.string   "resource_id",   limit: 255,   null: false
      t.string   "resource_type", limit: 255,   null: false
      t.integer  "author_id",     limit: 4
      t.string   "author_type",   limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

    create_table "admin_users", force: :cascade do |t|
      t.string   "email",                  limit: 255, default: "", null: false
      t.string   "encrypted_password",     limit: 255, default: "", null: false
      t.string   "reset_password_token",   limit: 255
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip",     limit: 255
      t.string   "last_sign_in_ip",        limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
    add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

    create_table "gemgento_addresses", force: :cascade do |t|
      t.string   "addressable_type", limit: 255
      t.integer  "addressable_id",   limit: 4
      t.integer  "magento_id",       limit: 4
      t.string   "increment_id",     limit: 255
      t.string   "city",             limit: 255
      t.string   "company",          limit: 255
      t.integer  "country_id",       limit: 4
      t.string   "fax",              limit: 255
      t.string   "first_name",       limit: 255
      t.string   "middle_name",      limit: 255
      t.string   "last_name",        limit: 255
      t.string   "postcode",         limit: 255
      t.string   "prefix",           limit: 255
      t.string   "suffix",           limit: 255
      t.string   "region_name",      limit: 255
      t.integer  "region_id",        limit: 4
      t.string   "street",           limit: 255
      t.string   "telephone",        limit: 255
      t.boolean  "sync_needed",                  default: true,  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_billing",                   default: false
      t.boolean  "is_shipping",                  default: false
    end

    add_index "gemgento_addresses", ["addressable_type", "addressable_id"], name: "index_gemgento_addresses_on_addressable_type_and_addressable_id", using: :btree

    create_table "gemgento_api_jobs", force: :cascade do |t|
      t.integer  "source_id",       limit: 4
      t.string   "kind",            limit: 255
      t.string   "state",           limit: 255
      t.string   "source_type",     limit: 255
      t.string   "request_url",     limit: 255
      t.text     "request",         limit: 4294967295
      t.text     "response",        limit: 4294967295
      t.boolean  "locked"
      t.text     "request_body",    limit: 4294967295
      t.string   "request_status",  limit: 255
      t.string   "response_status", limit: 255
      t.string   "type",            limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "gemgento_asset_files", force: :cascade do |t|
      t.string   "file_file_name",    limit: 255
      t.string   "file_content_type", limit: 255
      t.integer  "file_file_size",    limit: 4
      t.datetime "file_updated_at"
      t.text     "file_meta",         limit: 65535
    end

    create_table "gemgento_asset_types", force: :cascade do |t|
      t.integer  "product_attribute_set_id", limit: 4
      t.string   "code",                     limit: 255
      t.string   "scope",                    limit: 255
      t.datetime "created_at",                           null: false
      t.datetime "updated_at",                           null: false
    end

    create_table "gemgento_assets", force: :cascade do |t|
      t.integer  "product_id",    limit: 4
      t.string   "url",           limit: 255
      t.integer  "position",      limit: 4
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
      t.string   "file",          limit: 255
      t.string   "label",         limit: 255
      t.boolean  "sync_needed",               default: true, null: false
      t.integer  "store_id",      limit: 4
      t.integer  "asset_file_id", limit: 4
    end

    add_index "gemgento_assets", ["product_id"], name: "index_gemgento_assets_on_product_id", using: :btree
    add_index "gemgento_assets", ["store_id"], name: "index_gemgento_assets_on_store_id", using: :btree

    create_table "gemgento_assets_asset_types", id: false, force: :cascade do |t|
      t.integer "asset_id",      limit: 4, default: 0, null: false
      t.integer "asset_type_id", limit: 4, default: 0, null: false
    end

    create_table "gemgento_attribute_set_attributes", id: false, force: :cascade do |t|
      t.integer "product_attribute_set_id", limit: 4, default: 0, null: false
      t.integer "product_attribute_id",     limit: 4, default: 0, null: false
    end

    add_index "gemgento_attribute_set_attributes", ["product_attribute_id"], name: "attribute_set_product_attributes_index", using: :btree
    add_index "gemgento_attribute_set_attributes", ["product_attribute_set_id", "product_attribute_id"], name: "attribute_set_attributes_index", unique: true, using: :btree

    create_table "gemgento_bundle_items", force: :cascade do |t|
      t.integer  "bundle_option_id",         limit: 4
      t.integer  "product_id",               limit: 4
      t.integer  "magento_id",               limit: 4
      t.integer  "price_type",               limit: 4
      t.float    "price_value",              limit: 24
      t.float    "default_quantity",         limit: 24
      t.boolean  "is_user_defined_quantity",            default: true
      t.integer  "position",                 limit: 4
      t.boolean  "is_default"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "gemgento_bundle_items", ["bundle_option_id"], name: "index_gemgento_bundle_items_on_bundle_option_id", using: :btree
    add_index "gemgento_bundle_items", ["product_id"], name: "index_gemgento_bundle_items_on_product_id", using: :btree

    create_table "gemgento_bundle_options", force: :cascade do |t|
      t.integer  "product_id",  limit: 4
      t.integer  "magento_id",  limit: 4
      t.string   "name",        limit: 255
      t.integer  "input_type",  limit: 4
      t.boolean  "is_required",             default: true
      t.integer  "position",    limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "gemgento_bundle_options", ["product_id"], name: "index_gemgento_bundle_options_on_product_id", using: :btree

    create_table "gemgento_categories", force: :cascade do |t|
      t.integer  "magento_id",         limit: 4
      t.string   "name",               limit: 255
      t.string   "url_key",            limit: 255
      t.integer  "parent_id",          limit: 4
      t.integer  "position",           limit: 4
      t.boolean  "is_active"
      t.datetime "created_at",                                      null: false
      t.datetime "updated_at",                                      null: false
      t.text     "all_children",       limit: 65535
      t.integer  "children_count",     limit: 4
      t.boolean  "include_in_menu",                  default: true, null: false
      t.string   "image_file_name",    limit: 255
      t.string   "image_content_type", limit: 255
      t.integer  "image_file_size",    limit: 4
      t.datetime "image_updated_at"
      t.datetime "deleted_at"
      t.text     "image_meta",         limit: 65535
    end

    add_index "gemgento_categories", ["magento_id"], name: "index_gemgento_categories_on_magento_id", unique: true, using: :btree

    create_table "gemgento_categories_stores", force: :cascade do |t|
      t.integer "category_id", limit: 4
      t.integer "store_id",    limit: 4
    end

    add_index "gemgento_categories_stores", ["category_id", "store_id"], name: "categories_index", unique: true, using: :btree
    add_index "gemgento_categories_stores", ["store_id"], name: "category_store_index", using: :btree

    create_table "gemgento_configurable_attributes", id: false, force: :cascade do |t|
      t.integer "product_id",           limit: 4, default: 0, null: false
      t.integer "product_attribute_id", limit: 4, default: 0, null: false
    end

    add_index "gemgento_configurable_attributes", ["product_attribute_id"], name: "configurable_attribute_product_attribute_index", using: :btree
    add_index "gemgento_configurable_attributes", ["product_id", "product_attribute_id"], name: "configurable_attributes_index", unique: true, using: :btree

    create_table "gemgento_configurable_simple_relations", id: false, force: :cascade do |t|
      t.integer "configurable_product_id", limit: 4, default: 0, null: false
      t.integer "simple_product_id",       limit: 4, default: 0, null: false
    end

    add_index "gemgento_configurable_simple_relations", ["configurable_product_id", "simple_product_id"], name: "configurable_simple_index", unique: true, using: :btree

    create_table "gemgento_countries", force: :cascade do |t|
      t.string   "magento_id", limit: 255, null: false
      t.string   "iso2_code",  limit: 255
      t.string   "iso3_code",  limit: 255
      t.string   "name",       limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "gemgento_gift_messages", force: :cascade do |t|
      t.integer "magento_id", limit: 4
      t.string  "to",         limit: 255
      t.string  "from",       limit: 255
      t.text    "message",    limit: 65535
    end

    create_table "gemgento_image_imports", force: :cascade do |t|
      t.text     "import_errors",            limit: 65535
      t.string   "spreadsheet_file_name",    limit: 255
      t.string   "spreadsheet_content_type", limit: 255
      t.integer  "spreadsheet_file_size",    limit: 4
      t.datetime "spreadsheet_updated_at"
      t.boolean  "destroy_existing",                       default: false
      t.integer  "store_id",                 limit: 4
      t.integer  "count_created",            limit: 4
      t.integer  "count_updated",            limit: 4
      t.string   "image_path",               limit: 255
      t.text     "image_labels",             limit: 65535
      t.text     "image_file_extensions",    limit: 65535
      t.text     "image_types",              limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_active",                              default: false
    end

    create_table "gemgento_inventories", force: :cascade do |t|
      t.integer  "product_id",                limit: 4,                 null: false
      t.integer  "quantity",                  limit: 4, default: 0,     null: false
      t.boolean  "is_in_stock",                         default: false, null: false
      t.boolean  "sync_needed",                         default: true,  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "store_id",                  limit: 4
      t.boolean  "use_default_website_stock",           default: true
      t.integer  "backorders",                limit: 4, default: 0,     null: false
      t.boolean  "use_config_backorders",               default: true,  null: false
      t.integer  "min_qty",                   limit: 4, default: 0,     null: false
      t.boolean  "use_config_min_qty",                  default: true,  null: false
      t.boolean  "manage_stock",                        default: true
    end

    add_index "gemgento_inventories", ["product_id", "store_id"], name: "inventories_index", unique: true, using: :btree
    add_index "gemgento_inventories", ["store_id"], name: "inventory_store_index", using: :btree

    create_table "gemgento_inventory_imports", force: :cascade do |t|
      t.string   "spreadsheet_file_name",    limit: 255
      t.string   "spreadsheet_content_type", limit: 255
      t.integer  "spreadsheet_file_size",    limit: 4
      t.datetime "spreadsheet_updated_at"
      t.text     "import_errors",            limit: 65535
      t.boolean  "is_active",                              default: true
    end

    create_table "gemgento_line_item_options", force: :cascade do |t|
      t.integer "line_item_id",   limit: 4
      t.integer "bundle_item_id", limit: 4
      t.float   "quantity",       limit: 24
    end

    add_index "gemgento_line_item_options", ["bundle_item_id"], name: "index_gemgento_line_item_options_on_bundle_item_id", using: :btree
    add_index "gemgento_line_item_options", ["line_item_id"], name: "index_gemgento_line_item_options_on_line_item_id", using: :btree

    create_table "gemgento_line_items", force: :cascade do |t|
      t.integer  "magento_id",                       limit: 4
      t.string   "itemizable_type",                  limit: 255,                            default: "Gemgento::Order"
      t.integer  "itemizable_id",                    limit: 4
      t.integer  "quote_item_id",                    limit: 4
      t.integer  "product_id",                       limit: 4
      t.string   "product_type",                     limit: 255
      t.text     "product_options",                  limit: 65535
      t.decimal  "weight",                                         precision: 12, scale: 4
      t.boolean  "is_virtual"
      t.string   "sku",                              limit: 255
      t.string   "name",                             limit: 255
      t.string   "applied_rule_ids",                 limit: 255
      t.boolean  "free_shipping"
      t.boolean  "is_qty_decimal"
      t.boolean  "no_discount"
      t.decimal  "qty_canceled",                                   precision: 12, scale: 4
      t.decimal  "qty_invoiced",                                   precision: 12, scale: 4
      t.decimal  "qty_ordered",                                    precision: 12, scale: 4
      t.decimal  "qty_refunded",                                   precision: 12, scale: 4
      t.decimal  "qty_shipped",                                    precision: 12, scale: 4
      t.decimal  "cost",                                           precision: 12, scale: 4
      t.decimal  "price",                                          precision: 12, scale: 4
      t.decimal  "base_price",                                     precision: 12, scale: 4
      t.decimal  "original_price",                                 precision: 12, scale: 4
      t.decimal  "base_original_price",                            precision: 12, scale: 4
      t.decimal  "tax_percent",                                    precision: 12, scale: 4
      t.decimal  "tax_amount",                                     precision: 12, scale: 4
      t.decimal  "base_tax_amount",                                precision: 12, scale: 4
      t.decimal  "tax_invoiced",                                   precision: 12, scale: 4
      t.decimal  "base_tax_invoiced",                              precision: 12, scale: 4
      t.decimal  "discount_percent",                               precision: 12, scale: 4
      t.decimal  "discount_amount",                                precision: 12, scale: 4
      t.decimal  "base_discount_amount",                           precision: 12, scale: 4
      t.decimal  "discount_invoiced",                              precision: 12, scale: 4
      t.decimal  "base_discount_invoiced",                         precision: 12, scale: 4
      t.decimal  "amount_refunded",                                precision: 12, scale: 4
      t.decimal  "base_amount_refunded",                           precision: 12, scale: 4
      t.decimal  "row_total",                                      precision: 12, scale: 4
      t.decimal  "base_row_total",                                 precision: 12, scale: 4
      t.decimal  "row_invoiced",                                   precision: 12, scale: 4
      t.decimal  "base_row_invoiced",                              precision: 12, scale: 4
      t.decimal  "row_weight",                                     precision: 12, scale: 4
      t.string   "gift_message_id",                  limit: 255
      t.string   "gift_message",                     limit: 255
      t.string   "gift_message_available",           limit: 255
      t.decimal  "base_tax_before_discount",                       precision: 12, scale: 4
      t.decimal  "tax_before_discount",                            precision: 12, scale: 4
      t.decimal  "weee_tax_applied",                               precision: 12, scale: 4
      t.decimal  "weee_tax_applied_amount",                        precision: 12, scale: 4
      t.decimal  "weee_tax_applied_row_amount",                    precision: 12, scale: 4
      t.decimal  "base_weee_tax_applied_amount",                   precision: 12, scale: 4
      t.decimal  "base_weee_tax_applied_row_amount",               precision: 12, scale: 4
      t.decimal  "weee_tax_disposition",                           precision: 12, scale: 4
      t.decimal  "weee_tax_row_disposition",                       precision: 12, scale: 4
      t.decimal  "base_weee_tax_disposition",                      precision: 12, scale: 4
      t.decimal  "base_weee_tax_row_disposition",                  precision: 12, scale: 4
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "options",                          limit: 65535
    end

    add_index "gemgento_line_items", ["itemizable_id"], name: "order_items_index", using: :btree
    add_index "gemgento_line_items", ["itemizable_type", "itemizable_id"], name: "index_gemgento_line_items_on_itemizable_type_and_itemizable_id", using: :btree
    add_index "gemgento_line_items", ["magento_id", "itemizable_type"], name: "index_gemgento_line_items_on_magento_id_and_itemizable_type", unique: true, using: :btree

    create_table "gemgento_magento_responses", force: :cascade do |t|
      t.text     "request",    limit: 65535
      t.text     "body",       limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "success",                     default: true, null: false
    end

    create_table "gemgento_order_statuses", force: :cascade do |t|
      t.integer  "order_id",             limit: 4,                  null: false
      t.integer  "increment_id",         limit: 4
      t.boolean  "is_active",                        default: true
      t.integer  "is_customer_notified", limit: 4,   default: 1
      t.string   "status",               limit: 255
      t.string   "comment",              limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "gemgento_order_statuses", ["order_id"], name: "order_statuses_index", using: :btree

    create_table "gemgento_orders", force: :cascade do |t|
      t.integer  "magento_id",                                 limit: 4
      t.integer  "store_id",                                   limit: 4,                            null: false
      t.integer  "user_id",                                    limit: 4
      t.decimal  "tax_amount",                                             precision: 12, scale: 4
      t.decimal  "shipping_amount",                                        precision: 12, scale: 4
      t.decimal  "discount_amount",                                        precision: 12, scale: 4
      t.decimal  "subtotal",                                               precision: 12, scale: 4
      t.decimal  "grand_total",                                            precision: 12, scale: 4
      t.decimal  "total_paid",                                             precision: 12, scale: 4
      t.decimal  "total_refunded",                                         precision: 12, scale: 4
      t.decimal  "total_qty_ordered",                                      precision: 12, scale: 4
      t.decimal  "total_canceled",                                         precision: 12, scale: 4
      t.decimal  "total_invoiced",                                         precision: 12, scale: 4
      t.decimal  "total_online_refunded",                                  precision: 12, scale: 4
      t.decimal  "total_offline_refunded",                                 precision: 12, scale: 4
      t.decimal  "base_tax_amount",                                        precision: 12, scale: 4
      t.decimal  "base_shipping_amount",                                   precision: 12, scale: 4
      t.decimal  "base_discount_amount",                                   precision: 12, scale: 4
      t.decimal  "base_subtotal",                                          precision: 12, scale: 4
      t.decimal  "base_grand_total",                                       precision: 12, scale: 4
      t.decimal  "base_total_paid",                                        precision: 12, scale: 4
      t.decimal  "base_total_refunded",                                    precision: 12, scale: 4
      t.decimal  "base_total_qty_ordered",                                 precision: 12, scale: 4
      t.decimal  "base_total_canceled",                                    precision: 12, scale: 4
      t.decimal  "base_total_invoiced",                                    precision: 12, scale: 4
      t.decimal  "base_total_online_refunded",                             precision: 12, scale: 4
      t.decimal  "base_total_offline_refunded",                            precision: 12, scale: 4
      t.integer  "billing_address_id",                         limit: 4
      t.string   "billing_first_name",                         limit: 255
      t.string   "billing_last_name",                          limit: 255
      t.integer  "shipping_address_id",                        limit: 4
      t.string   "shipping_first_name",                        limit: 255
      t.string   "shipping_last_name",                         limit: 255
      t.string   "billing_name",                               limit: 255
      t.string   "shipping_name",                              limit: 255
      t.string   "store_to_base_rate",                         limit: 255
      t.string   "store_to_order_rate",                        limit: 255
      t.string   "base_to_global_rate",                        limit: 255
      t.string   "base_to_order_rate",                         limit: 255
      t.decimal  "weight",                                                 precision: 12, scale: 4
      t.string   "store_name",                                 limit: 255
      t.string   "remote_ip",                                  limit: 255
      t.string   "status",                                     limit: 255
      t.string   "state",                                      limit: 255
      t.string   "applied_rule_ids",                           limit: 255
      t.string   "global_currency_code",                       limit: 255
      t.string   "base_currency_code",                         limit: 255
      t.string   "store_currency_code",                        limit: 255
      t.string   "order_currency_code",                        limit: 255
      t.string   "shipping_method",                            limit: 255
      t.string   "shipping_description",                       limit: 255
      t.string   "customer_email",                             limit: 255
      t.string   "customer_firstname",                         limit: 255
      t.string   "customer_lastname",                          limit: 255
      t.boolean  "is_virtual"
      t.integer  "user_group_id",                              limit: 4
      t.string   "customer_note_notify",                       limit: 255
      t.boolean  "customer_is_guest"
      t.boolean  "email_sent"
      t.string   "increment_id",                               limit: 255
      t.string   "gift_message_id",                            limit: 255
      t.string   "gift_message",                               limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "placed_at"
      t.integer  "quote_id",                                   limit: 4
      t.decimal  "base_giftvoucher_discount_for_shipping",                 precision: 10
      t.decimal  "giftvoucher_discount_for_shipping",                      precision: 10
      t.decimal  "base_giftcredit_discount_for_shipping",                  precision: 10
      t.decimal  "giftcredit_discount_for_shipping",                       precision: 10
      t.decimal  "base_gift_voucher_discount",                             precision: 10
      t.decimal  "gift_voucher_discount",                                  precision: 10
      t.decimal  "base_use_gift_credit_amount",                            precision: 10
      t.decimal  "use_gift_credit_amount",                                 precision: 10
      t.decimal  "giftvoucher_base_hidden_tax_amount",                     precision: 10
      t.decimal  "giftvoucher_hidden_tax_amount",                          precision: 10
      t.decimal  "giftcredit_base_hidden_tax_amount",                      precision: 10
      t.decimal  "giftcredit_hidden_tax_amount",                           precision: 10
      t.decimal  "giftcredit_base_shipping_hidden_tax_amount",             precision: 10
      t.decimal  "giftcredit_shipping_hidden_tax_amount",                  precision: 10
    end

    add_index "gemgento_orders", ["increment_id"], name: "index_gemgento_orders_on_increment_id", unique: true, using: :btree
    add_index "gemgento_orders", ["magento_id"], name: "index_gemgento_orders_on_magento_id", unique: true, using: :btree
    add_index "gemgento_orders", ["quote_id"], name: "index_gemgento_orders_on_quote_id", using: :btree

    create_table "gemgento_orders_recurring_profiles", id: false, force: :cascade do |t|
      t.integer "order_id",             limit: 4
      t.integer "recurring_profile_id", limit: 4
    end

    add_index "gemgento_orders_recurring_profiles", ["order_id", "recurring_profile_id"], name: "order_recurring_profile_index", using: :btree
    add_index "gemgento_orders_recurring_profiles", ["recurring_profile_id"], name: "recurring_profile_index", using: :btree

    create_table "gemgento_payments", force: :cascade do |t|
      t.integer  "magento_id",           limit: 4
      t.string   "payable_type",         limit: 255,                          default: "Gemgento::Order"
      t.integer  "payable_id",           limit: 4,                                                        null: false
      t.integer  "increment_id",         limit: 4
      t.boolean  "is_active",                                                 default: true
      t.decimal  "amount_ordered",                   precision: 12, scale: 4
      t.decimal  "shipping_amount",                  precision: 12, scale: 4
      t.decimal  "base_amount_ordered",              precision: 12, scale: 4
      t.decimal  "base_shipping_amount",             precision: 12, scale: 4
      t.string   "method",               limit: 255
      t.string   "po_number",            limit: 255
      t.string   "cc_type",              limit: 255
      t.string   "cc_number_enc",        limit: 255
      t.string   "cc_last4",             limit: 255
      t.string   "cc_owner",             limit: 255
      t.string   "cc_exp_month",         limit: 255
      t.string   "cc_exp_year",          limit: 255
      t.string   "cc_ss_start_month",    limit: 255
      t.string   "cc_ss_start_year",     limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "gemgento_payments", ["payable_id"], name: "order_payments_index", using: :btree
    add_index "gemgento_payments", ["payable_type", "payable_id"], name: "index_gemgento_payments_on_payable_type_and_payable_id", using: :btree

    create_table "gemgento_price_rules", force: :cascade do |t|
      t.integer  "magento_id",            limit: 4
      t.string   "name",                  limit: 255
      t.text     "description",           limit: 65535
      t.datetime "from_date"
      t.datetime "to_date"
      t.boolean  "is_active",                                          default: false, null: false
      t.boolean  "stop_rules_processing",                              default: true,  null: false
      t.integer  "sort_order",            limit: 4
      t.string   "simple_action",         limit: 255
      t.decimal  "discount_amount",                     precision: 10
      t.boolean  "sub_is_enable",                                      default: false, null: false
      t.string   "sub_simple_action",     limit: 255
      t.decimal  "sub_discount_amount",                 precision: 10
      t.text     "conditions",            limit: 65535
    end

    create_table "gemgento_price_rules_stores", id: false, force: :cascade do |t|
      t.integer "price_rule_id", limit: 4
      t.integer "store_id",      limit: 4
    end

    add_index "gemgento_price_rules_stores", ["price_rule_id", "store_id"], name: "index_gemgento_price_rules_stores_on_price_rule_id_and_store_id", using: :btree
    add_index "gemgento_price_rules_stores", ["store_id"], name: "index_gemgento_price_rules_stores_on_store_id", using: :btree

    create_table "gemgento_price_rules_user_groups", force: :cascade do |t|
      t.integer "price_rule_id", limit: 4
      t.integer "user_group_id", limit: 4
    end

    add_index "gemgento_price_rules_user_groups", ["price_rule_id", "user_group_id"], name: "price_rule_user_group_index", using: :btree
    add_index "gemgento_price_rules_user_groups", ["user_group_id"], name: "user_group_index", using: :btree

    create_table "gemgento_price_tiers", force: :cascade do |t|
      t.integer "product_id",    limit: 4
      t.integer "store_id",      limit: 4
      t.integer "user_group_id", limit: 4
      t.decimal "quantity",                precision: 5, scale: 2
      t.decimal "price",                   precision: 5, scale: 2
    end

    add_index "gemgento_price_tiers", ["product_id"], name: "index_gemgento_price_tiers_on_product_id", using: :btree
    add_index "gemgento_price_tiers", ["store_id"], name: "index_gemgento_price_tiers_on_store_id", using: :btree
    add_index "gemgento_price_tiers", ["user_group_id"], name: "index_gemgento_price_tiers_on_user_group_id", using: :btree

    create_table "gemgento_product_attribute_options", force: :cascade do |t|
      t.integer  "product_attribute_id", limit: 4
      t.string   "label",                limit: 255
      t.string   "value",                limit: 255
      t.boolean  "sync_needed",                      default: true, null: false
      t.datetime "created_at",                                      null: false
      t.datetime "updated_at",                                      null: false
      t.integer  "order",                limit: 4
      t.integer  "store_id",             limit: 4
    end

    add_index "gemgento_product_attribute_options", ["product_attribute_id", "store_id"], name: "attribute_options_index", using: :btree
    add_index "gemgento_product_attribute_options", ["store_id"], name: "product_attribute_option_store_index", using: :btree

    create_table "gemgento_product_attribute_sets", force: :cascade do |t|
      t.integer  "magento_id",  limit: 4
      t.string   "name",        limit: 255
      t.datetime "created_at",                             null: false
      t.datetime "updated_at",                             null: false
      t.boolean  "sync_needed",             default: true, null: false
      t.datetime "deleted_at"
    end

    create_table "gemgento_product_attribute_values", force: :cascade do |t|
      t.integer  "product_id",           limit: 4
      t.integer  "product_attribute_id", limit: 4
      t.text     "value",                limit: 65535
      t.datetime "created_at",                         null: false
      t.datetime "updated_at",                         null: false
      t.integer  "store_id",             limit: 4
    end

    add_index "gemgento_product_attribute_values", ["product_attribute_id"], name: "product_attribute_values_product_attribute_index", using: :btree
    add_index "gemgento_product_attribute_values", ["product_id"], name: "product_attribute_values_index", using: :btree

    create_table "gemgento_product_attributes", force: :cascade do |t|
      t.integer  "magento_id",                    limit: 4
      t.string   "code",                          limit: 255
      t.string   "frontend_input",                limit: 255
      t.string   "scope",                         limit: 255
      t.boolean  "is_unique"
      t.boolean  "is_required"
      t.boolean  "is_configurable"
      t.boolean  "is_searchable"
      t.boolean  "is_visible_in_advanced_search"
      t.boolean  "is_comparable"
      t.boolean  "is_used_for_promo_rules"
      t.boolean  "is_visible_on_front"
      t.boolean  "used_in_product_listing"
      t.boolean  "sync_needed",                                 default: true, null: false
      t.datetime "created_at",                                                 null: false
      t.datetime "updated_at",                                                 null: false
      t.text     "default_value",                 limit: 65535
      t.datetime "deleted_at"
    end

    create_table "gemgento_product_categories", force: :cascade do |t|
      t.integer  "category_id", limit: 4
      t.integer  "product_id",  limit: 4
      t.integer  "position",    limit: 4, default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "store_id",    limit: 4
    end

    add_index "gemgento_product_categories", ["category_id"], name: "product_categories_category_index", using: :btree
    add_index "gemgento_product_categories", ["product_id", "category_id", "store_id"], name: "uniqueness_constraint", unique: true, using: :btree
    add_index "gemgento_product_categories", ["product_id"], name: "product_categories_product_index", using: :btree

    create_table "gemgento_product_imports", force: :cascade do |t|
      t.text     "import_errors",                   limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "spreadsheet_file_name",           limit: 255
      t.string   "spreadsheet_content_type",        limit: 255
      t.integer  "spreadsheet_file_size",           limit: 4
      t.datetime "spreadsheet_updated_at"
      t.boolean  "include_images"
      t.string   "image_path",                      limit: 255
      t.text     "image_labels",                    limit: 65535
      t.integer  "store_id",                        limit: 4
      t.integer  "root_category_id",                limit: 4
      t.integer  "product_attribute_set_id",        limit: 4
      t.integer  "count_created",                   limit: 4
      t.integer  "count_updated",                   limit: 4
      t.integer  "simple_product_visibility",       limit: 4
      t.integer  "configurable_product_visibility", limit: 4
      t.text     "image_file_extensions",           limit: 65535
      t.text     "image_types",                     limit: 65535
      t.boolean  "set_default_inventory_values",                  default: false
    end

    create_table "gemgento_product_imports_configurable_attributes", id: false, force: :cascade do |t|
      t.integer "product_import_id",    limit: 4, default: 0, null: false
      t.integer "product_attribute_id", limit: 4, default: 0, null: false
    end

    create_table "gemgento_products", force: :cascade do |t|
      t.integer  "magento_id",               limit: 4
      t.string   "magento_type",             limit: 255
      t.datetime "created_at",                                          null: false
      t.datetime "updated_at",                                          null: false
      t.string   "sku",                      limit: 255
      t.string   "product_attribute_set_id", limit: 255
      t.boolean  "status",                               default: true
      t.integer  "visibility",               limit: 4,   default: 4
      t.datetime "deleted_at"
      t.datetime "cache_expires_at"
    end

    create_table "gemgento_products_tags", id: false, force: :cascade do |t|
      t.integer "product_id", limit: 4
      t.integer "tag_id",     limit: 4
    end

    add_index "gemgento_products_tags", ["product_id", "tag_id"], name: "index_gemgento_products_tags_on_product_id_and_tag_id", using: :btree
    add_index "gemgento_products_tags", ["tag_id"], name: "index_gemgento_products_tags_on_tag_id", using: :btree

    create_table "gemgento_quotes", force: :cascade do |t|
      t.integer  "magento_id",                        limit: 4
      t.integer  "store_id",                          limit: 4
      t.integer  "user_id",                           limit: 4
      t.integer  "user_group_id",                     limit: 4
      t.datetime "converted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_active",                                                                default: true
      t.boolean  "is_virtual",                                                               default: false
      t.boolean  "is_multi_shipping",                                                        default: false
      t.string   "original_order_id",                 limit: 255
      t.decimal  "store_to_base_rate",                              precision: 12, scale: 4, default: 1.0
      t.decimal  "store_to_quote_rate",                             precision: 12, scale: 4, default: 1.0
      t.string   "base_currency_code",                limit: 255
      t.string   "store_currency_code",               limit: 255
      t.string   "quote_currency_code",               limit: 255
      t.decimal  "grand_total",                                     precision: 12, scale: 4
      t.decimal  "base_grand_total",                                precision: 12, scale: 4
      t.string   "checkout_method",                   limit: 255
      t.string   "customer_email",                    limit: 255
      t.string   "customer_prefix",                   limit: 255
      t.string   "customer_first_name",               limit: 255
      t.string   "customer_middle_name",              limit: 255
      t.string   "customer_last_name",                limit: 255
      t.string   "customer_suffix",                   limit: 255
      t.text     "customer_note",                     limit: 65535
      t.boolean  "customer_note_notify",                                                     default: false
      t.boolean  "customer_is_guest",                                                        default: false
      t.string   "applied_rule_ids",                  limit: 255
      t.string   "reserved_order_id",                 limit: 255
      t.string   "password_hash",                     limit: 255
      t.string   "coupon_code",                       limit: 255
      t.string   "global_currency_code",              limit: 255
      t.decimal  "base_to_global_rate",                             precision: 12, scale: 4, default: 1.0
      t.decimal  "base_to_order_rate",                              precision: 12, scale: 4, default: 1.0
      t.string   "customer_taxvat",                   limit: 255
      t.string   "customer_gender",                   limit: 255
      t.decimal  "subtotal",                                        precision: 12, scale: 4
      t.decimal  "base_subtotal",                                   precision: 12, scale: 4
      t.decimal  "base_subtotal_with_discount",                     precision: 12, scale: 4
      t.string   "shipping_method",                   limit: 255
      t.text     "ext_shipping_info",                 limit: 65535
      t.decimal  "shipping_amount",                                 precision: 12, scale: 4
      t.integer  "gift_message_id",                   limit: 4
      t.text     "gift_message",                      limit: 65535
      t.decimal  "customer_balance_amount_used",                    precision: 12, scale: 4
      t.decimal  "base_customer_balance_amount_used",               precision: 12, scale: 4
      t.boolean  "use_customer_balance",                                                     default: false
      t.decimal  "gift_cards_amount",                               precision: 12, scale: 4
      t.decimal  "base_gift_cards_amount",                          precision: 12, scale: 4
      t.boolean  "use_reward_points",                                                        default: false
      t.decimal  "reward_points_balance",                           precision: 12, scale: 4
      t.decimal  "reward_currency_amount",                          precision: 12, scale: 4
      t.decimal  "base_reward_currency_amount",                     precision: 12, scale: 4
      t.text     "coupon_codes",                      limit: 65535
      t.text     "gift_card_codes",                   limit: 65535
    end

    create_table "gemgento_recurring_profiles", force: :cascade do |t|
      t.integer  "magento_id",            limit: 4
      t.string   "state",                 limit: 255
      t.integer  "user_id",               limit: 4
      t.integer  "store_id",              limit: 4
      t.string   "method_code",           limit: 255
      t.integer  "reference_id",          limit: 4
      t.string   "subscriber_name",       limit: 255
      t.datetime "start_datetime"
      t.string   "internal_reference_id", limit: 255
      t.string   "schedule_description",  limit: 255
      t.string   "period_unit",           limit: 255
      t.integer  "period_frequency",      limit: 4
      t.decimal  "billing_amount",                      precision: 8, scale: 2
      t.string   "currency_code",         limit: 255
      t.decimal  "shipping_amount",                     precision: 8, scale: 2
      t.decimal  "tax_amount",                          precision: 8, scale: 2
      t.text     "order_info",            limit: 65535
      t.text     "order_item_info",       limit: 65535
      t.text     "billing_address_info",  limit: 65535
      t.text     "shipping_address_info", limit: 65535
      t.text     "profile_vendor_info",   limit: 65535
      t.text     "additional_info",       limit: 65535
    end

    add_index "gemgento_recurring_profiles", ["store_id"], name: "index_gemgento_recurring_profiles_on_store_id", using: :btree
    add_index "gemgento_recurring_profiles", ["user_id"], name: "index_gemgento_recurring_profiles_on_user_id", using: :btree

    create_table "gemgento_regions", force: :cascade do |t|
      t.integer  "magento_id", limit: 4,   null: false
      t.string   "code",       limit: 255
      t.string   "name",       limit: 255
      t.integer  "country_id", limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "gemgento_relation_types", force: :cascade do |t|
      t.string   "name",        limit: 255
      t.text     "description", limit: 65535
      t.string   "applies_to",  limit: 255
      t.datetime "created_at",                null: false
      t.datetime "updated_at",                null: false
    end

    create_table "gemgento_relations", force: :cascade do |t|
      t.integer  "relation_type_id", limit: 4
      t.integer  "relatable_id",     limit: 4
      t.string   "relatable_type",   limit: 255
      t.integer  "related_to_id",    limit: 4
      t.string   "related_to_type",  limit: 255
      t.datetime "created_at",                   null: false
      t.datetime "updated_at",                   null: false
    end

    create_table "gemgento_saved_credit_cards", force: :cascade do |t|
      t.integer  "magento_id", limit: 4
      t.integer  "user_id",    limit: 4
      t.string   "token",      limit: 255
      t.string   "cc_number",  limit: 255
      t.integer  "exp_month",  limit: 4
      t.integer  "exp_year",   limit: 4
      t.string   "cc_type",    limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_in_use",              default: false
    end

    create_table "gemgento_sessions", force: :cascade do |t|
      t.string   "session_id", limit: 255
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
    end

    create_table "gemgento_shipment_comments", force: :cascade do |t|
      t.integer  "shipment_id",          limit: 4
      t.text     "comment",              limit: 65535
      t.boolean  "is_customer_notified"
      t.integer  "magento_id",           limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "gemgento_shipment_items", force: :cascade do |t|
      t.integer "shipment_id",  limit: 4
      t.string  "sku",          limit: 255
      t.string  "name",         limit: 255
      t.integer "line_item_id", limit: 4
      t.integer "product_id",   limit: 4
      t.float   "weight",       limit: 24
      t.float   "price",        limit: 24
      t.float   "qty",          limit: 24
      t.integer "magento_id",   limit: 4
      t.decimal "quantity",                 precision: 10, default: 0, null: false
    end

    add_index "gemgento_shipment_items", ["shipment_id"], name: "shipment_items_shipment_id", using: :btree

    create_table "gemgento_shipment_tracks", force: :cascade do |t|
      t.integer "shipment_id",  limit: 4
      t.string  "carrier_code", limit: 255
      t.string  "title",        limit: 255
      t.string  "number",       limit: 255
      t.integer "order_id",     limit: 4
      t.integer "magento_id",   limit: 4
    end

    add_index "gemgento_shipment_tracks", ["shipment_id"], name: "shipment_tracks_shipment_index", using: :btree

    create_table "gemgento_shipments", force: :cascade do |t|
      t.integer  "magento_id",          limit: 4
      t.integer  "order_id",            limit: 4
      t.string   "increment_id",        limit: 255
      t.integer  "store_id",            limit: 4
      t.integer  "shipping_address_id", limit: 4
      t.float    "total_qty",           limit: 24
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "gemgento_shipments", ["order_id"], name: "shipments_order_index", using: :btree

    create_table "gemgento_shopify_adapters", force: :cascade do |t|
      t.integer  "gemgento_model_id",   limit: 4
      t.string   "gemgento_model_type", limit: 255
      t.string   "shopify_model_type",  limit: 255
      t.integer  "shopify_model_id",    limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "gemgento_shopify_adapters", ["gemgento_model_id", "gemgento_model_type"], name: "gemgento_model_index", using: :btree
    add_index "gemgento_shopify_adapters", ["shopify_model_id", "shopify_model_type"], name: "shopify_model_index", using: :btree

    create_table "gemgento_stock_notifications", force: :cascade do |t|
      t.integer  "product_id",   limit: 4
      t.string   "product_name", limit: 255
      t.string   "product_url",  limit: 255
      t.string   "name",         limit: 255
      t.string   "email",        limit: 255
      t.string   "phone",        limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "gemgento_store_tags", force: :cascade do |t|
      t.integer "store_id",        limit: 4
      t.integer "tag_id",          limit: 4
      t.integer "base_popularity", limit: 4, default: 0
    end

    add_index "gemgento_store_tags", ["store_id"], name: "index_gemgento_store_tags_on_store_id", using: :btree
    add_index "gemgento_store_tags", ["tag_id"], name: "index_gemgento_store_tags_on_tag_id", using: :btree

    create_table "gemgento_stores", force: :cascade do |t|
      t.integer  "magento_id",    limit: 4,                   null: false
      t.string   "code",          limit: 255
      t.integer  "group_id",      limit: 4
      t.string   "name",          limit: 255
      t.integer  "sort_order",    limit: 4
      t.boolean  "is_active",                 default: true,  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "website_id",    limit: 4
      t.string   "currency_code", limit: 255, default: "usd"
    end

    add_index "gemgento_stores", ["magento_id"], name: "index_gemgento_stores_on_magento_id", unique: true, using: :btree

    create_table "gemgento_stores_products", force: :cascade do |t|
      t.integer "product_id", limit: 4
      t.integer "store_id",   limit: 4
    end

    add_index "gemgento_stores_products", ["product_id", "store_id"], name: "stores_products_index", unique: true, using: :btree
    add_index "gemgento_stores_products", ["store_id"], name: "store_product_store_index", using: :btree

    create_table "gemgento_stores_users", force: :cascade do |t|
      t.integer "store_id", limit: 4
      t.integer "user_id",  limit: 4
    end

    create_table "gemgento_subscribers", force: :cascade do |t|
      t.string   "first_name", limit: 255
      t.string   "last_name",  limit: 255
      t.string   "email",      limit: 255
      t.integer  "country_id", limit: 4
      t.string   "city",       limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "gemgento_syncs", force: :cascade do |t|
      t.string   "subject",     limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_complete",             default: false
    end

    create_table "gemgento_tags", force: :cascade do |t|
      t.integer "magento_id",  limit: 4
      t.string  "name",        limit: 255
      t.string  "status",      limit: 255, default: "0"
      t.boolean "sync_needed",             default: false
    end

    create_table "gemgento_user_groups", force: :cascade do |t|
      t.integer  "magento_id", limit: 4
      t.string   "code",       limit: 255
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
    end

    create_table "gemgento_users", force: :cascade do |t|
      t.integer  "magento_id",             limit: 4
      t.string   "created_in",             limit: 255
      t.string   "email",                  limit: 255, default: "", null: false
      t.string   "first_name",             limit: 255
      t.string   "last_name",              limit: 255
      t.string   "middle_name",            limit: 255
      t.integer  "user_group_id",          limit: 4
      t.string   "prefix",                 limit: 255
      t.string   "suffix",                 limit: 255
      t.date     "dob"
      t.string   "taxvat",                 limit: 255
      t.boolean  "confirmation"
      t.string   "magento_password",       limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "increment_id",           limit: 4
      t.string   "encrypted_password",     limit: 255, default: "", null: false
      t.string   "reset_password_token",   limit: 255
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          limit: 4,   default: 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip",     limit: 255
      t.string   "last_sign_in_ip",        limit: 255
      t.string   "unencrypted_password",   limit: 255
      t.string   "type",                   limit: 255
      t.string   "gender",                 limit: 255
      t.datetime "deleted_at"
    end

    add_index "gemgento_users", ["email", "deleted_at"], name: "users_email_deleted_index", unique: true, using: :btree
    add_index "gemgento_users", ["magento_id"], name: "index_gemgento_users_on_magento_id", unique: true, using: :btree
    add_index "gemgento_users", ["reset_password_token"], name: "index_gemgento_users_on_reset_password_token", unique: true, using: :btree

    create_table "gemgento_wishlist_items", force: :cascade do |t|
      t.integer  "product_id", limit: 4
      t.integer  "user_id",    limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end
end
