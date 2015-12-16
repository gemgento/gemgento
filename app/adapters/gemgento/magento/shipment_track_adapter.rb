module Gemgento
  class Magento::ShipmentTrackAdapter

    attr_accessor :source, :shipment

    # @param source [Hash]
    # @param shipment [Gemgento::Shipment]
    def initialize(source, shipment = nil)
      @source = source
      @shipment = shipment
    end

    # @return [Gemgento::ShipmentTrackAdapter]
    def import
      shipment_track = Gemgento::ShipmentTrack.find_or_initialize_by(magento_id: self.source[:track_id])
      shipment_track.shipment = self.shipment
      shipment_track.carrier_code = self.source[:carrier_code]
      shipment_track.title = self.source[:title]
      shipment_track.number = self.source[:number]
      shipment_track.save!

      return shipment_track
    end

    # @return [Gemgento::Shipment]
    def shipment
      @shipment ||= Gemgento::Shipment.find_by!(magento_id: self.source[:parent_id])
    end

  end
end