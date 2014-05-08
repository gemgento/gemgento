class AddMetaToAttachedImages < ActiveRecord::Migration
  def change
    add_column :gemgento_asset_files, :file_meta, :text
    add_column :gemgento_categories, :image_meta, :text
  end
end
