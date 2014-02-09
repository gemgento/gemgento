module Gemgento
  module API
    module SOAP
      module Sales
        class OrderShipment

          def self.add_comment(shipment_comment, email = nil, include_in_email = nil)
            message = {
                shipment_increment_id: shipment_comment.shipment.increment_id,
                comment: shipment_comment.comment,
                email: email,
                include_in_email: include_in_email
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_add_comment, message)

            return response.success?
          end

          def self.add_track(shipment_track)
            message = {
                shipment_increment_id: shipment_track.shipment.increment_id,
                carrier: shipment_track.carrier,
                title: shipment_track.title,
                track_number: shipment_track.number
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_add_track, message)

            return response.success?
          end

          def self.create(order_increment_id, email = nil, comment = nil, include_comment = nil)
            message = {
                order_increment_id: order_increment_id,
                email: email,
                comment: comment,
                include_comment: include_comment
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_create, message)

            if response.success?
              return response.body[:shipment_increment_id]
            else
              return false
            end
          end

          def self.get_carriers(order_increment_id)
            message = {
                order_increment_id: order_increment_id,
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_get_carriers, message)

            if response.success?
              if response.body[:result][:item].nil?
                return response.body[:result]
              else
                response.body[:result][:item]
              end
            else
              return false
            end
          end

          def self.info(shipment_increment_id)
            message = {
                shipment_increment_id: shipment_increment_id,
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_info, message)

            if response.success?
              return response.body[:result]
            else
              return nil
            end
          end

          def self.list
            response = Gemgento::Magento.create_call(:sales_order_shipment_list)

            if response.success?
              return response.body[:result]
            else
              return false
            end
          end

          def self.remove_track(shipment_increment_id, track_id)
            message = {
                shipment_increment_id: shipment_increment_id,
                track_id: track_id
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_remove_track, message)

            return response.success?
          end

        end
      end
    end
  end
end