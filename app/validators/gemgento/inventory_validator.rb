module Gemgento
  class InventoryValidator < ActiveModel::Validator

    # Validate LineItem Product inventory levels.
    #
    # @param line_item [Gemgento::LineItem]
    def validate(line_item)
      unless line_item.product.in_stock?(line_item.qty_ordered, line_item.itemizable.store)
        line_item.errors.add(:base, 'Requested quantity is not available')
      end
    end

  end
end