module Gemgento
  class Magento::ShipmentAdapter

    attr_accessor :source, :order, :shipment

    # @param increment_id [Integer]
    # @return [Gemgento::Magento::Shipment]
    def self.find(increment_id)
      response = Gemgento::API::SOAP::Sales::OrderShipment.info(increment_id)

      if response.success?
        source = response.body[:result]
        
        source[:items] = source[:items][:item].nil? ? [] : source[:items][:item]
        source[:items] = [source[:items]] unless source[:items].is_a? Array
        
        source[:comments] = source[:comments][:item].nil? ? [] : source[:comments][:item]
        source[:comments] = [source[:comments]] unless source[:comments].is_a? Array

        source[:tracks] = source[:tracks][:item].nil? ? [] : source[:tracks][:item]
        source[:tracks] = [source[:tracks]] unless source[:tracks].is_a? Array
        
        return new(source)
      else
        raise response.body[:faultstring]
      end
    end

    # @param source [Hash]
    def initialize(source)
      Rails.logger.debug 'Gemgento::Magento::Shipment.new:'
      Rails.logger.debug source
      @source = source
    end

    # @return [Gemgento::Shipment]
    def import
      shipment = self.order.shipments.find_or_initialize_by(magento_id: self.source[:shipment_id])
      shipment.order = self.order
      shipment.increment_id = self.source[:increment_id]
      shipment.save!

      # import shipment items
      self.source[:items].each do |item|
        Gemgento::Magento::ShipmentItemAdapter.new(item, shipment).import
      end

      # remove any shipment items not referenced in most recent items list
      Gemgento::ShipmentItem
          .where(shipment: shipment)
          .where.not(magento_id: self.source[:items].map { |i| i[:item_id] })
          .destroy_all

      # import tracks
      self.source[:tracks].each do |track|
        Gemgento::Magento::ShipmentTrackAdapter.new(track, shipment).import
      end

      # remove any tracks not referenced in most recent tracks list
      Gemgento::ShipmentTrack
          .where(shipment: shipment)
          .where.not(magento_id: self.source[:tracks].map { |t| t[:track_id] })
          .destroy_all

      return shipment
    end

    # @return [Gemgento::Order]
    def order
      @order ||= Gemgento::Order.find_by!(magento_id: self.source[:order_id])
    end

  end
end