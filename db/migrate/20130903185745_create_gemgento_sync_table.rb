class CreateGemgentoSyncTable < ActiveRecord::Migration
  def change
    create_table :gemgento_syncs do |t|
      t.string :subject
      t.timestamps
    end
  end
end
