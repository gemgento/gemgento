class CreateGemgentoBundleItem < ActiveRecord::Migration
  def change
    create_table :gemgento_bundle_items do |t|
      t.references :bundle_option, index: true
      t.references :product, index: true
      t.float :default_quantity
      t.boolean :is_user_defined_quantity, default: true
      t.integer :position
      t.boolean :is_default

      t.timestamps
    end
  end
end
