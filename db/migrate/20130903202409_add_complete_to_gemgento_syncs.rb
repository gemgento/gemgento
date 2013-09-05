class AddCompleteToGemgentoSyncs < ActiveRecord::Migration
  def up
    add_column :gemgento_syncs, :is_complete, :boolean, default: false
  end

  def down
    remove_column :gemgento_syncs, :is_complete
  end
end
