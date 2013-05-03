class UpdateGemgentoCategorySyncNeeded < ActiveRecord::Migration
  def up
    change_column :gemgento_categories, :sync_needed, :boolean, null: false, default: true
  end

  def down
    cahnge_column :gemgento_categories, :sync_needed, :boolean, null: true, default: nil
  end
end
