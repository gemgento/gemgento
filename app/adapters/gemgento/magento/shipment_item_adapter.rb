module Gemgento
  class Magento::ShipmentItemAdapter

    attr_accessor :source

    # @param source [Hash]
    def initialize(source)
      @source = source
    end

    # @return [Gemgento::ShipmentItemAdapter]
    def import
      shipment_item = self.shipment.shipment_items.find_or_initialize_by(magento_id: self.source[:item_id])
      shipment_item.line_item = self.order.line_items.find_by!(magento_id: self.source[:order_item_id])
      shipment_item.sku = self.source[:sku]
      shipment_item.name = self.source[:name]
      shipment_item.weight = self.source[:weight]
      shipment_item.price = self.source[:price]
      shipment_item.quantity = self.source[:qty]
      shipment_item.save!

      return shipment_item
    end

    # @return [Gemgento::Shipment]
    def shipment
      @shipment ||= Gemgento::Shipment.find_by!(magento_id: self.source[:parent_id])
    end

    # @return [Gemgento::Order]
    def order
      @order ||= self.shipment.order
    end

  end
end