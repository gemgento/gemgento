class CreateGemgentoImports < ActiveRecord::Migration
  def change
    create_table :gemgento_imports do |t|
      t.string :type
      t.attachment :file
      t.integer :total_rows, null: false, default: 0
      t.integer :current_row, null: false, default: 0
      t.text :options
      t.integer :state, null: false, default: 0
      t.text :process_errors

      t.timestamps null: false
    end
  end
end
