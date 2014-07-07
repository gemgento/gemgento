class CreateGemgentoAdapterShopifyAdapter < ActiveRecord::Migration

  def up
    create_table :gemgento_shopify_adapters do |t|
      t.references :gemgento_model, polymorphic: true
      t.string :shopify_model_type
      t.integer :shopify_model_id
      t.timestamps
    end

    add_index :gemgento_shopify_adapters, [:gemgento_model_id, :gemgento_model_type], name: 'gemgento_model_index'
    add_index :gemgento_shopify_adapters, [:shopify_model_id, :shopify_model_type], name: 'shopify_model_index'
  end

  def down
    drop_table :gemgento_shopify_adapters
  end

end
