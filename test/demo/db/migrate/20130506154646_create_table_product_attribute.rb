class CreateTableProductAttribute < ActiveRecord::Migration
  def change
    create_table :gemgento_product_attributes do |t|
      t.integer    :magento_id
      t.integer    :product_attribute_set_id, null: false
      t.string     :code
      t.string     :frontend_input
      t.string     :scope
      t.boolean    :is_unique
      t.boolean    :is_required
      t.boolean    :is_configurable
      t.boolean    :is_searchable
      t.boolean    :is_visible_in_advanced_search
      t.boolean    :is_comparable
      t.boolean    :is_used_for_promo_rules
      t.boolean    :is_visible_on_front
      t.boolean    :used_in_product_listing
      t.boolean    :sync_needed, null: false, default: true
      t.timestamps
    end

  end
end
