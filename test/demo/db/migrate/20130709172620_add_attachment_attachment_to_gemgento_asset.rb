class AddAttachmentAttachmentToGemgentoAsset < ActiveRecord::Migration
  def self.up
    change_table :gemgento_assets do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :gemgento_assets, :attachment
  end
end
