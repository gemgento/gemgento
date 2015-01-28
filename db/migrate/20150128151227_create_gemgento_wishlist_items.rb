class CreateGemgentoWishlistItems < ActiveRecord::Migration
  def change
    create_table :gemgento_wishlist_items do |t|
      t.integer :product_id
      t.integer :user_id

      t.timestamps
    end
  end
end
