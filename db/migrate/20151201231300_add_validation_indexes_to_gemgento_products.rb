class AddValidationIndexesToGemgentoProducts < ActiveRecord::Migration
  def change
    add_index :gemgento_products, :magento_id, unique: true
    add_index :gemgento_products, [:sku, :deleted_at], unique: true
  end

  def migrate(direction)
    if direction == :up
      # remove duplicates on magento_id
      products = Gemgento::Product.order(:deleted_at)
      grouped = products.group_by{ |model| model.magento_id }

      grouped.values.each do |duplicates|
        next if duplicates.size == 1
        original = duplicates.shift
        duplicates.each { |dup| dup.destroy }
      end
    end

    super
  end
end
