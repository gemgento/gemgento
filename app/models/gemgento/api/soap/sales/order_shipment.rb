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
                carrier: shipment_track.carrier_code,
                title: shipment_track.title,
                track_number: shipment_track.number
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_add_track, message)

            return response.success?
          end

          def self.create(shipment)
            message = {
                order_increment_id: shipment.order.increment_id,
                email: shipment.email,
                comment: shipment.comment,
                include_comment: shipment.include_comment
            }

            if shipment.shipment_items.any?
              message[:items_qty] = {item: compose_items_qty(shipment.shipment_items)}
            end

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

          def self.send_info(shipment_increment_id, comment = '')
            message = {
                shipment_increment_id: shipment_increment_id,
                comment: comment
            }
            response = Gemgento::Magento.create_call(:sales_order_shipment_send_info, message)

            return response.success?
          end

          private

          def self.compose_items_qty(shipment_items)
            items_qty = []

            shipment_items.each do |shipment_item|
              items_qty << {
                  'order_item_id' => shipment_item.order_item.magento_id,
                  qty: shipment_item.quantity
              }
            end

            return items_qty
          end

        end
      end
    end
  end
end
