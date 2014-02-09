module Gemgento
  module API
    module SOAP
      module Sales
        class OrderShipment

          def add_comment(shipment_comment, email = nil, include_in_email = nil)
            message = {
                shipment_increment_id: shipment_comment.shipment.increment_id,
                comment: shipment_comment.comment,
                email: email,
                include_in_email: include_in_email
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_add_comment, message)

            return response.success?
          end

          def add_track(shipment_track)
            message = {
                shipment_increment_id: shipment_track.shipment.increment_id,
                carrier: shipment_track.carrier,
                title: shipment_track.title,
                track_number: shipment_track.number
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_add_track, message)

            return response.success?
          end

          def create(order_increment_id, email = nil, comment = nil, include_comment = nil)
            message = {
                order_increment_id: order_increment_id,
                email: email,
                comment: comment,
                include_comment: include_comment
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_create, message)

            if response.success?
              shipment.increment_id = response['shipmentIncrementId']
              shipment.save

              return true
            else
              return false
            end
          end

          def get_carriers(order_increment_id)
            message = {
                order_increment_id: order_increment_id,
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_get_carriers, message)

            if response.success?
              return response[:result]
            else
              return nil
            end
          end

          def info(shipment_increment_id)
            message = {
                shipment_increment_id: shipment_increment_id,
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_info, message)

            if response.success?
              return response[:result]
            else
              return nil
            end
          end

          def list
            response = Gemgento::Magento.create_call(:sales_order_shipment_list)

            if response.success?
              return response[:result]
            else
              return nil
            end
          end

          def remove_track(shipment_increment_id, track_id)
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