class AddUniqueIndexesToGemgentoOrders < ActiveRecord::Migration
  def change
    add_index :gemgento_orders, :increment_id, unique: true
    add_index :gemgento_orders, :magento_id, unique: true
  end

  def migrate(direction)

    if direction == :up
      # remove duplicates
      %w[increment_id magento_id].each do |col|
        grouped = Gemgento::Order.all.group_by{ |model| [model.attributes[col]] }
        grouped.values.each do |duplicates|
          next if duplicates.size == 1
          original = duplicates.shift # or pop for last one
          duplicates.each { |dup| dup.destroy }
          Gemgento::API::SOAP::Sales::Order.fetch(original.increment_id)
        end
      end
    end

    super
  end
end
