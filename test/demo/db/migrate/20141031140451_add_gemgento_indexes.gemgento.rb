# This migration comes from gemgento (originally 20140207154554)
class AddGemgentoIndexes < ActiveRecord::Migration
  def change
    add_index :gemgento_assets, :product_id
    add_index :gemgento_assets, :store_id

    add_index :gemgento_attribute_set_attributes, [:product_attribute_set_id, :product_attribute_id], unique: true, name: 'attribute_set_attributes_index'
    add_index :gemgento_attribute_set_attributes, :product_attribute_id, name: 'attribute_set_product_attributes_index'

    add_index :gemgento_categories_stores, [:category_id, :store_id], unique: true, name: 'categories_index'
    add_index :gemgento_categories_stores, :store_id, name: 'category_store_index'

    add_index :gemgento_configurable_attributes, [:product_id, :product_attribute_id], unique: true, name: 'configurable_attributes_index'
    add_index :gemgento_configurable_attributes, :product_attribute_id, name: 'configurable_attribute_product_attribute_index'

    add_index :gemgento_inventories, [:product_id, :store_id], unique: true, name: 'inventories_index'
    add_index :gemgento_inventories, :store_id, name: 'inventory_store_index'

    add_index :gemgento_order_items, :order_id, name: 'order_items_index'
    add_index :gemgento_order_payments, :order_id, name: 'order_payments_index'
    add_index :gemgento_order_statuses, :order_id, name: 'order_statuses_index'

    add_index :gemgento_product_attribute_options, [:product_attribute_id, :store_id], name: 'attribute_options_index'
    add_index :gemgento_product_attribute_options, :store_id, name: 'product_attribute_option_store_index'

    add_index :gemgento_product_attribute_values, :product_id, name: 'product_attribute_values_index'
    add_index :gemgento_product_attribute_values, :product_attribute_id, name: 'product_attribute_values_product_attribute_index'

    add_index :gemgento_configurable_simple_relations, [:configurable_product_id, :simple_product_id], unique: true, name: 'configurable_simple_index'

    add_index :gemgento_product_categories, :category_id, name: 'product_categories_category_index'
    add_index :gemgento_product_categories, :product_id, name: 'product_categories_product_index'

    add_index :gemgento_stores_products, [:product_id, :store_id], unique: true, name: 'stores_products_index'
    add_index :gemgento_stores_products, :store_id, name: 'store_product_store_index'
  end
end
