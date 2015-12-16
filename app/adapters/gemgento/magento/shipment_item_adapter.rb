module Gemgento
  class Magento::ShipmentItemAdapter

    attr_accessor :source, :shipment

    # @param source [Hash]
    # @param shipment [Gemgento::Shipment]
    def initialize(source, shipment = nil)
      @source = source
      @shipment = shipment
    end

    # @return [Gemgento::ShipmentItemAdapter]
    def import
      shipment_item = Gemgento::ShipmentItem.find_or_initialize_by(magento_id: self.source[:item_id])
      shipment_item.shipment = self.shipment
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