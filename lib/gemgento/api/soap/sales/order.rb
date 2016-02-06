module Gemgento
  module API
    module SOAP
      module Sales
        class Order

          def self.fetch_all(last_updated = nil)
            response = list(last_updated)

            if response.success?
              response.body_overflow[:result][:item].each do |order|
                unless order.nil?
                  fetch(order[:increment_id])
                end
              end
            end

          end

          # Fetch a Magento Order.
          #
          # @param increment_id [String] Order increment id.
          # @return [Gemgento::Order]
          def self.fetch(increment_id)
            response = info(increment_id)

            if response.success?
              sync_magento_to_local(response.body[:result])
            else
              return nil
            end
          end

          # Get a list of orders from Magento.
          #
          # @param last_updated [String] db formatted datetime string.
          # @return [Gemgento::MagentoResponse]
          def self.list(last_updated = nil)
            if last_updated.nil?
              message = {}
            else
              message = {
                  'filters' => {
                      'complex_filter' => {item: [
                          key: 'updated_at',
                          value: {
                              key: 'gt',
                              value: last_updated
                          }
                      ]}
                  }
              }
            end

            response = ::Gemgento::MagentoApi.create_call(:sales_order_list, message)

            if response.success? && !response.body_overflow[:result][:item].is_a?(Array)
              response.body_overflow[:result][:item] = [response.body_overflow[:result][:item]]
            end

            return response
          end

          # Get Order info from Magento.
          #
          # @param increment_id [String]
          # @return [Gemgento::MagentoResponse]
          def self.info(increment_id)
            ::Gemgento::MagentoApi.create_call(:sales_order_info, { order_increment_id: increment_id })
          end

          def self.hold
            # TODO: Create hold API call
          end

          def self.unhold
            # TODO: Create unhold API call
          end

          def self.cancel
            # TODO: Create cancel API call
          end

          def self.add_comment(increment_id, status, comment = '', notify = nil)
            message = {
              order_increment_id: increment_id,
              status: status,
              comment: comment,
              notify: notify
            }
            MagentoApi.create_call(:sales_order_add_comment, message)
          end

          private

          # Save Magento order to local
          #
          # @return [::Gemgento::Order]
          def self.sync_magento_to_local(source)
            return nil if ::Gemgento::Store.find_by(magento_id: source[:store_id]).nil?

            retry_count ||= 0

            order = ::Gemgento::Order.find_or_initialize_by(increment_id: source[:increment_id])
            order.magento_id = source[:order_id]
            order.user = ::Gemgento::User.find_by(magento_id: source[:customer_id])
            order.quote = ::Gemgento::Quote.find_by(magento_id: source[:quote_id])
            order.user_group = ::Gemgento::UserGroup.where(magento_id: source[:customer_group_id]).first
            order.store = ::Gemgento::Store.find_by(magento_id: source[:store_id])

            source.each do |k, v|
              next if [:store_id, :quote_id].include?(k) || !Gemgento::Order.column_names.include?(k.to_s)
              order.assign_attributes k => v
            end

            order.save! validate: false

            sync_magento_address_to_local(source[:shipping_address], order, order.shipping_address) unless source[:shipping_address][:address_id].nil?
            sync_magento_address_to_local(source[:billing_address], order, order.billing_address) unless source[:billing_address][:address_id].nil?

            sync_magento_payment_to_local(source[:payment], order)

            unless source[:gift_message_id].nil?
              gift_message = ::Gemgento::API::SOAP::EnterpriseGiftMessage::GiftMessage.sync_magento_to_local(source[:gift_message])
              order.gift_message = gift_message
              order.save! validate: false
            end

            # import line items
            unless source[:items][:item].nil?
              source[:items][:item] = [source[:items][:item]] unless source[:items][:item].is_a? Array
              source[:items][:item].each do |item|
                sync_magento_line_item_to_local(item, order)
              end
            end

            # remove unused line items
            known_ids = source[:items][:item].map { |i| i[:item_id] }
            Gemgento::LineItem.where(itemizable: order).where.not(magento_id: known_ids).destroy_all

            if !source[:status_history][:item].nil?
              source[:status_history][:item] = [source[:status_history][:item]] unless source[:status_history][:item].is_a? Array

              source[:status_history][:item].each do |status|
                sync_magento_order_status_to_local(status, order)
              end
            end

            order.reload
            return order

          # try one more time to create the record, duplicate record errors are common with threads
          rescue ActiveRecord::RecordInvalid => e
            (retry_count += 1) <= 1 ? retry : raise(e)

          rescue ActiveRecord::RecordNotUnique => e
            (retry_count += 1) <= 1 ? retry : raise(e)
          end

          def self.sync_magento_address_to_local(source, order, address = nil)
            address = ::Gemgento::Address.new if address.nil?
            address.addressable = order
            address.increment_id = source[:increment_id]
            address.city = source[:city]
            address.company = source[:company]
            address.country = ::Gemgento::Country.where(magento_id: source[:country_id]).first
            address.fax = source[:fax]
            address.first_name = source[:firstname]
            address.middle_name = source[:middlename]
            address.last_name = source[:lastname]
            address.postcode = source[:postcode]
            address.prefix = source[:prefix]
            address.region_name = source[:region]
            address.region = ::Gemgento::Region.where(magento_id: source[:region_id]).first
            address.street = source[:street]
            address.suffix = source[:suffix]
            address.telephone = source[:telephone]
            address.is_billing = (source[:address_type] == 'billing')
            address.is_shipping = (source[:address_type] == 'shipping')
            address.sync_needed = false
            address.save! validate: false

            return address
          end

          def self.sync_magento_payment_to_local(source, order)
            payment = ::Gemgento::Payment.where(magento_id: source[:payment_id].to_i).first_or_initialize
            payment.payable = order
            payment.magento_id = source[:payment_id]
            payment.increment_id = source[:increment_id]
            payment.is_active = source[:is_active]
            payment.amount_ordered = source[:amount_ordered]
            payment.shipping_amount = source[:shipping_amount]
            payment.base_amount_ordered = source[:base_amount_ordered]
            payment.base_shipping_amount = source[:base_shipping_amount]
            payment.method = source[:method]
            payment.po_number = source[:po_number]
            payment.cc_type = source[:cc_type]
            payment.cc_number_enc = source[:cc_number_enc]
            payment.cc_last4 = source[:cc_last4]
            payment.cc_owner = source[:cc_owner]
            payment.cc_exp_month = source[:cc_exp_month]
            payment.cc_exp_year = source[:cc_exp_year]
            payment.cc_ss_start_month = source[:cc_ss_start_month]
            payment.cc_ss_start_year = source[:cc_ss_start_year]
            payment.save! validate: false

            payment
          end

          def self.sync_magento_order_status_to_local(source, order)
            order_status = ::Gemgento::OrderStatus.find_or_initialize_by(order_id: order.id, status: source[:status], comment: source[:comment])
            order_status.order = order
            order_status.status = source[:status]
            order_status.is_active = source[:is_active]
            order_status.is_customer_notified = source[:is_customer_notified].to_i
            order_status.comment = source[:comment]
            order_status.created_at = source[:created_at]
            order_status.save

            order_status
          end

          def self.sync_magento_line_item_to_local(source, order)
            line_item = ::Gemgento::LineItem.find_or_initialize_by(itemizable_type: 'Gemgento::Order', magento_id: source[:item_id])
            line_item.itemizable = order
            line_item.product = ::Gemgento::Product.find_by(magento_id: source[:product_id])

            source.each do |k, v|
              next if [:product_id].include?(k) || !Gemgento::LineItem.column_names.include?(k.to_s)
              line_item.assign_attributes k => v
            end

            unless source[:gift_message_id].nil?
              gift_message = ::Gemgento::API::SOAP::EnterpriseGiftMessage::GiftMessage.sync_magento_to_local(source[:gift_message])
              line_item.gift_message = gift_message
              line_item.save
            end

            return line_item

          rescue ActiveRecord::RecordNotUnique
            return ::Gemgento::LineItem.find_by(itemizable_type: 'Gemgento::Order', magento_id: source[:item_id])
          end
        end
      end
    end
  end
end