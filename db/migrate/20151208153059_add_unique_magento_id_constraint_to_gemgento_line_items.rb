class AddUniqueMagentoIdConstraintToGemgentoLineItems < ActiveRecord::Migration
  def change
    add_index :gemgento_line_items, [:magento_id, :itemizable_type]
  end

  def migrate(direction)
    if direction == :up
      # remove duplicates
      line_items = Gemgento::LineItem.where.not(magento_id: nil)
      grouped = line_items.group_by{ |model| model.magento_id }

      grouped.values.each do |duplicates|
        next if duplicates.size == 1
        original = duplicates.shift
        duplicates.each { |dup| dup.destroy }
      end
    end

    super
  end
end
