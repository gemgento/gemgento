class CreateGemgentoBundleOption < ActiveRecord::Migration
  def change
    create_table :gemgento_bundle_options do |t|
      t.references :product, index: true
      t.string :name
      t.integer :input_type
      t.boolean :is_required, default: true
      t.integer :position

      t.timestamps
    end
  end
end
