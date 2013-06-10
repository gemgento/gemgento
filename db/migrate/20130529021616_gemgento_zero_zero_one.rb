class GemgentoZeroZeroOne < ActiveRecord::Migration
  def change
    create_table "gemgento_asset_types", :force => true do |t|
      t.integer  "product_attribute_set_id"
      t.string   "code"
      t.string   "scope"
      t.datetime "created_at",               :null => false
      t.datetime "updated_at",               :null => false
    end

    create_table "gemgento_assets", :force => true do |t|
      t.integer  "product_id"
      t.string   "url"
      t.integer  "position"
      t.datetime "created_at",                    :null => false
      t.datetime "updated_at",                    :null => false
      t.string   "file"
      t.string   "label"
      t.boolean  "sync_needed", :default => true, :null => false
    end

    create_table "gemgento_assets_asset_types", :id => false, :force => true do |t|
      t.integer "asset_id",      :default => 0, :null => false
      t.integer "asset_type_id", :default => 0, :null => false
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

    create_table "gemgento_categories_products", :id => false, :force => true do |t|
      t.integer "product_id",  :default => 0, :null => false
      t.integer "category_id", :default => 0, :null => false
    end

    create_table "gemgento_configurable_attributes", :id => false, :force => true do |t|
      t.integer "product_id",           :default => 0, :null => false
      t.integer "product_attribute_id", :default => 0, :null => false
    end

    create_table "gemgento_product_attribute_options", :force => true do |t|
      t.integer  "product_attribute_id"
      t.string   "label"
      t.string   "value"
      t.integer  "sync_needed",          :limit => 1, :default => 1, :null => false
      t.datetime "created_at",                                       :null => false
      t.datetime "updated_at",                                       :null => false
    end

    create_table "gemgento_product_attribute_sets", :force => true do |t|
      t.integer  "magento_id"
      t.string   "name"
      t.datetime "created_at",                    :null => false
      t.datetime "updated_at",                    :null => false
      t.boolean  "sync_needed", :default => true, :null => false
    end

    create_table "gemgento_product_attribute_values", :force => true do |t|
      t.integer  "product_id"
      t.integer  "product_attribute_id"
      t.text     "value"
      t.datetime "created_at",           :null => false
      t.datetime "updated_at",           :null => false
    end

    create_table "gemgento_product_attributes", :force => true do |t|
      t.integer  "magento_id"
      t.integer  "product_attribute_set_id",                        :null => false
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
      t.boolean  "sync_needed",                   :default => true, :null => false
      t.datetime "created_at",                                      :null => false
      t.datetime "updated_at",                                      :null => false
    end

    create_table "gemgento_products", :force => true do |t|
      t.integer  "magento_id"
      t.string   "magento_type"
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
      t.string   "sku"
      t.string   "product_attribute_set_id"
      t.string   "store_view"
      t.boolean  "sync_needed",              :default => true, :null => false
      t.integer  "parent_id"
    end

    create_table "gemgento_sessions", :force => true do |t|
      t.string   "session_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

  end
end