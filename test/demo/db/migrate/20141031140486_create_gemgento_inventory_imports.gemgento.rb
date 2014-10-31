# This migration comes from gemgento (originally 20140829172323)
class CreateGemgentoInventoryImports < ActiveRecord::Migration
  def change
    create_table :gemgento_inventory_imports do |t|
      t.attachment :spreadsheet
      t.text :import_errors
      t.boolean :is_active, default: true
    end
  end
end
