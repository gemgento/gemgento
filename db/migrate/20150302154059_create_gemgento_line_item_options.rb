class CreateGemgentoLineItemOptions < ActiveRecord::Migration
  def change
    create_table :gemgento_line_item_options do |t|
      t.references :line_item, index: true
      t.references :bundle_item, index: true
      t.float :quantity
    end
  end
end
