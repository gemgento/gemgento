module Gemgento
  class Magento::ShipmentTrack

    attr_accessor :source

    def initialize(source)
      @source = source
    end

    # @return [Gemgento::ShipmentTrack]
    def import
      shipment_track = self.shipment.shipment_tracks.find_or_initialize_by(magento_id: self.source[:track_id])
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