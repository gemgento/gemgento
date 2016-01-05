class AddUniqeIndexForGemgentoProductCategories < ActiveRecord::Migration
  def change
    add_index :gemgento_product_categories, [:product_id, :category_id, :store_id], unique: true, name: 'uniqueness_constraint'
  end

  def migrate(direction)
    if direction == :up
      # remove duplicates
      line_items = Gemgento::ProductCategory.all
      grouped = line_items.group_by{ |model| [model.product_id, model.category_id, model.store_id] }

      grouped.values.each do |duplicates|
        next if duplicates.size == 1
        original = duplicates.shift
        duplicates.each { |dup| dup.destroy }
      end
    end

    super
  end
end
