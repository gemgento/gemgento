module Gemgento
  class Magento::LineItemAdapter

    attr_accessor :source, :itemizable

    def initialize(source, itemizable)
      @source = source
      @itemizable = itemizable
    end

    def import
      retries ||= 0

      line_item = Gemgento::LineItem.find_or_initialize_by(itemizable_type: 'Gemgento::Order', magento_id: self.source[:item_id])
      line_item.itemizable = self.itemizable
      line_item.product = Gemgento::Product.find_by!(magento_id: self.source[:product_id])

      self.source.each do |k, v|
        next if [:product_id].include?(k) || !Gemgento::LineItem.column_names.include?(k.to_s)
        line_item.assign_attributes k => v
      end

      line_item.save!

      return line_item

    rescue ActiveRecord::RecordNotUnique
      if retries < 1
        retries += 1
        retry

      elsif line_item = Gemgento::LineItem.find_by(itemizable_type: 'Gemgento::Order', magento_id: self.source[:item_id])
        return line_item

      else
        raise
      end
    end

  end
end