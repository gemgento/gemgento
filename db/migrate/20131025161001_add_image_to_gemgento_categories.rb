class AddImageToGemgentoCategories < ActiveRecord::Migration
  def change
    add_attachment :gemgento_categories, :image
  end
end
