module Gemgento
  module API
    module SOAP
      module Sales
        class Order

          def self.fetch_all(last_updated = nil)
            list(last_updated).each do |order|
              unless order.nil?
                fetch(order[:increment_id])
              end
            end
          end

          def self.fetch(increment_id)
            info = info(increment_id)

            unless info == false
              sync_magento_to_local(info)
              return true
            end
            return false
          end

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

            response = Gemgento::Magento.create_call(:sales_order_list, message)

            if response.success?
              unless response.body_overflow[:result][:item].is_a? Array
                response.body_overflow[:result][:item] = [response.body_overflow[:result][:item]]
              end

              response.body_overflow[:result][:item]
            end
          end

          def self.info(increment_id)
            response = Gemgento::Magento.create_call(:sales_order_info, {order_increment_id: increment_id})

            if response.success?
              return response.body[:result]
            else
              return false
            end
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

          def self.add_comment
            # TODO: Create addComment API call
          end

          private

          # Save Magento order to local
          def self.sync_magento_to_local(source)
            order = Gemgento::Order.where(increment_id: source[:increment_id]).first_or_initialize
            order.order_id = source[:order_id]
            order.is_active = source[:is_active]
            order.user = User.find_by(magento_id: source[:customer_id])
            order.tax_amount = source[:tax_amount]
            order.shipping_amount = source[:shipping_amount]
            order.discount_amount = source[:discount_amount]
            order.subtotal = source[:subtotal]
            order.grand_total = source[:grand_total]
            order.total_paid = source[:total_paid]
            order.total_refunded = source[:total_refunded]
            order.total_qty_ordered = source[:total_qty_ordered]
            order.total_canceled = source[:total_canceled]
            order.total_invoiced = source[:total_invoiced]
            order.total_online_refunded = source[:total_online_refunded]
            order.total_offline_refunded = source[:total_offline_refunded]
            order.base_tax_amount = source[:base_tax_amount]
            order.base_shipping_amount = source[:base_shipping_amount]
            order.base_discount_amount = source[:base_discount_amount]
            order.base_subtotal = source[:base_subtotal]
            order.base_grand_total = source[:base_grand_total]
            order.base_total_paid = source[:base_total_paid]
            order.base_total_refunded = source[:base_total_refunded]
            order.base_total_qty_ordered = source[:base_total_qty_ordered]
            order.base_total_canceled = source[:base_total_canceled]
            order.base_total_invoiced = source[:base_total_invoiced]
            order.base_total_online_refunded = source[:base_total_online_refunded]
            order.base_total_offline_refunded = source[:base_total_offline_refunded]
            order.store_to_base_rate = source[:store_to_base_rate]
            order.store_to_order_rate = source[:store_to_order_rate]
            order.base_to_global_rate = source[:base_to_global_rate]
            order.base_to_order_rate = source[:base_to_order_rate]
            order.weight = source[:weight]
            order.store_name = source[:store_name]
            order.remote_ip = source[:remote_ip]
            order.status = source[:status]
            order.state = source[:state]
            order.applied_rule_ids = source[:applied_rule_ids]
            order.global_currency_code = source[:global_currency_code]
            order.base_currency_code = source[:base_currency_code]
            order.store_currency_code = source[:store_currency_code]
            order.order_currency_code = source[:order_currency_code]
            order.shipping_method = source[:shipping_method]
            order.shipping_description = source[:shipping_description]
            order.customer_email = source[:customer_email]
            order.customer_firstname = source[:customer_firstname]
            order.customer_lastname = source[:customer_lastname]
            order.magento_quote_id = source[:quote_id]
            order.is_virtual = source[:is_virtual]
            order.user_group = UserGroup.where(magento_id: source[:customer_group_id]).first
            order.customer_note_notify = source[:customer_note_notify]
            order.customer_is_guest = source[:customer_is_guest]
            order.email_sent = source[:email_sent]
            order.increment_id = source[:increment_id]
            order.placed_at = source[:created_at]
            order.store = Gemgento::Store.find_by(magento_id: source[:store_id])
            order.save

            order.shipping_address = sync_magento_address_to_local(source[:shipping_address], order, order.shipping_address)
            order.billing_address = sync_magento_address_to_local(source[:billing_address], order, order.billing_address)
            order.save

            sync_magento_payment_to_local(source[:payment], order)

            unless source[:gift_message_id].nil?
              gift_message = Gemgento::API::SOAP::EnterpriseGiftMessage::GiftMessage.sync_magento_to_local(source[:gift_message])
              order.gift_message = gift_message
              order.save
            end

            order.order_items.destroy_all
            unless source[:items][:item].nil?
              source[:items][:item] = [source[:items][:item]] unless source[:items][:item].is_a? Array
              source[:items][:item].each do |item|
                sync_magento_order_item_to_local(item, order)
              end
            end

            if !source[:status_history][:item].nil?
              source[:status_history][:item] = [source[:status_history][:item]] unless source[:status_history][:item].is_a? Array

              source[:status_history][:item].each do |status|
                sync_magento_order_status_to_local(status, order)
              end
            end
          end

          def self.sync_magento_address_to_local(source, order, address = nil)
            address = Gemgento::Address.where(order_address_id: source[:address_id].to_i).first_or_initialize if address.nil?
            address.order_address_id = source[:address_id]
            address.order = order
            address.user = order.user
            address.increment_id = source[:increment_id]
            address.city = source[:city]
            address.company = source[:company]
            address.country = Country.where(magento_id: source[:country_id]).first
            address.fax = source[:fax]
            address.first_name = source[:firstname]
            address.middle_name = source[:middlename]
            address.last_name = source[:lastname]
            address.postcode = source[:postcode]
            address.prefix = source[:prefix]
            address.region_name = source[:region]
            address.region = Region.where(magento_id: source[:region_id]).first
            address.street = source[:street]
            address.suffix = source[:suffix]
            address.telephone = source[:telephone]
            address.is_default = source[:is_default_billing] || source[:is_default_shipping] ? 1 : 0
            address.address_type = source[:address_type]
            address.sync_needed = false
            address.save validate: false

            return address
          end

          def self.sync_magento_payment_to_local(source, order)
            payment = Gemgento::OrderPayment.where(magento_id: source[:payment_id].to_i).first_or_initialize
            payment.order = order
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
            payment.save validate: false

            payment
          end

          def self.sync_magento_order_status_to_local(source, order)
            order_status = Gemgento::OrderStatus.where(order_id: order.id, status: source[:status], comment: source[:comment]).first_or_initialize
            order_status.order = order
            order_status.status = source[:status]
            order_status.is_active = source[:is_active]
            order_status.is_customer_notified = source[:is_customer_notified].to_i
            order_status.comment = source[:comment]
            order_status.created_at = source[:created_at]
            order_status.save

            order_status
          end

          def self.sync_magento_order_item_to_local(source, order)
            order_item = Gemgento::OrderItem.find_or_initialize_by(magento_id: source[:item_id])
            order_item.order = order
            order_item.magento_id = source[:item_id]
            order_item.quote_item_id = source[:quote_item_id]
            order_item.product = Gemgento::Product.find_by(magento_id: source[:product_id])
            order_item.product_type = source[:product_type]
            order_item.product_options = source[:product_options]
            order_item.weight = source[:weight]
            order_item.is_virtual = source[:is_virtual]
            order_item.sku = source[:sku]
            order_item.name = source[:name]
            order_item.applied_rule_ids = source[:applied_rule_ids]
            order_item.free_shipping = source[:free_shipping]
            order_item.is_qty_decimal = source[:is_qty_decimal]
            order_item.no_discount = source[:no_discount]
            order_item.qty_canceled = source[:qty_canceled]
            order_item.qty_invoiced = source[:qty_invoiced]
            order_item.qty_ordered = source[:qty_ordered]
            order_item.qty_refunded = source[:qty_refunded]
            order_item.qty_shipped = source[:qty_shipped]
            order_item.cost = source[:cost]
            order_item.price = source[:price]
            order_item.base_price = source[:base_price]
            order_item.original_price = source[:original_price]
            order_item.base_original_price = source[:base_original_price]
            order_item.tax_percent = source[:tax_percent]
            order_item.tax_amount = source[:tax_amount]
            order_item.base_tax_amount = source[:base_tax_amount]
            order_item.tax_invoiced = source[:tax_invoiced]
            order_item.base_tax_invoiced = source[:base_tax_invoiced]
            order_item.discount_percent = source[:discount_percent]
            order_item.discount_amount = source[:discount_amount]
            order_item.base_discount_amount = source[:base_discount_amount]
            order_item.discount_invoiced = source[:discount_invoiced]
            order_item.base_discount_invoiced = source[:base_discount_invoiced]
            order_item.amount_refunded = source[:amount_refunded]
            order_item.base_amount_refunded = source[:base_amount_refunded]
            order_item.row_total = source[:row_total]
            order_item.base_row_total = source[:base_row_total]
            order_item.row_invoiced = source[:row_invoiced]
            order_item.base_row_invoiced = source[:base_row_invoiced]
            order_item.row_weight = source[:row_weight]
            order_item.base_tax_before_discount = source[:base_tax_before_discount]
            order_item.tax_before_discount = source[:tax_before_discount]
            order_item.weee_tax_applied = source[:weee_tax_applied]
            order_item.weee_tax_applied_amount = source[:weee_tax_applied_amount]
            order_item.weee_tax_applied_row_amount = source[:weee_tax_applied_row_amount]
            order_item.base_weee_tax_applied_amount = source[:base_weee_tax_applied_amount]
            order_item.base_weee_tax_applied_row_amount = source[:base_weee_tax_applied_row_amount]
            order_item.weee_tax_disposition = source[:weee_tax_disposition]
            order_item.weee_tax_row_disposition = source[:weee_tax_row_disposition]
            order_item.base_weee_tax_disposition = source[:base_weee_tax_disposition]
            order_item.base_weee_tax_row_disposition = source[:base_weee_tax_row_disposition]
            order_item.save

            unless source[:gift_message_id].nil?
              gift_message = Gemgento::API::SOAP::EnterpriseGiftMessage::GiftMessage.sync_magento_to_local(source[:gift_message])
              order_item.gift_message = gift_message
              order_item.save
            end

            order_item
          end
        end
      end
    end
  end
end