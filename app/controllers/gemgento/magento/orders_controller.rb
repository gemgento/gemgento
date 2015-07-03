module Gemgento
  module Magento
    class OrdersController < Gemgento::Magento::BaseController

      def update
        data = params[:data]

        @order = Order.where('id = ? OR magento_id = ?', params[:id], data[:order_id]).first_or_initialize
        @order.magento_id = data[:order_id]
        @order.user = User.find_by(magento_id: data[:customer_id])
        @order.tax_amount = data[:tax_amount]
        @order.shipping_amount = data[:shipping_amount]
        @order.discount_amount = data[:discount_amount]
        @order.subtotal = data[:subtotal]
        @order.grand_total = data[:grand_total]
        @order.total_paid = data[:total_paid]
        @order.total_refunded = data[:total_refunded]
        @order.total_qty_ordered = data[:total_qty_ordered]
        @order.total_canceled = data[:total_canceled]
        @order.total_invoiced = data[:total_invoiced]
        @order.total_online_refunded = data[:total_online_refunded]
        @order.total_offline_refunded = data[:total_offline_refunded]
        @order.base_tax_amount = data[:base_tax_amount]
        @order.base_shipping_amount = data[:base_shipping_amount]
        @order.base_discount_amount = data[:base_discount_amount]
        @order.base_subtotal = data[:base_subtotal]
        @order.base_grand_total = data[:base_grand_total]
        @order.base_total_paid = data[:base_total_paid]
        @order.base_total_refunded = data[:base_total_refunded]
        @order.base_total_qty_ordered = data[:base_total_qty_ordered]
        @order.base_total_canceled = data[:base_total_canceled]
        @order.base_total_invoiced = data[:base_total_invoiced]
        @order.base_total_online_refunded = data[:base_total_online_refunded]
        @order.base_total_offline_refunded = data[:base_total_offline_refunded]
        @order.store_to_base_rate = data[:store_to_base_rate]
        @order.store_to_order_rate = data[:store_to_order_rate]
        @order.base_to_global_rate = data[:base_to_global_rate]
        @order.base_to_order_rate = data[:base_to_order_rate]
        @order.weight = data[:weight]
        @order.store_name = data[:store_name]
        @order.remote_ip = data[:remote_ip]
        @order.status = data[:status]
        @order.state = data[:state] unless data[:state].nil?
        @order.applied_rule_ids = data[:applied_rule_ids]
        @order.global_currency_code = data[:global_currency_code]
        @order.base_currency_code = data[:base_currency_code]
        @order.store_currency_code = data[:store_currency_code]
        @order.order_currency_code = data[:order_currency_code]
        @order.shipping_method = data[:shipping_method]
        @order.shipping_description = data[:shipping_description]
        @order.customer_email = data[:customer_email]
        @order.customer_firstname = data[:customer_firstname]
        @order.customer_lastname = data[:customer_lastname]
        @order.is_virtual = data[:is_virtual]
        @order.user_group = UserGroup.find_by(magento_id: data[:customer_group_id])
        @order.customer_note_notify = data[:customer_note_notify]
        @order.customer_is_guest = data[:customer_is_guest]
        @order.email_sent = data[:email_sent]
        @order.increment_id = data[:increment_id]
        @order.placed_at = data[:created_at]
        @order.store = Store.find_by(magento_id: data[:store_id])
        @order.quote = Gemgento::Quote.find_by(magento_id: data[:quote_id])
        @order.save

        sync_address(data[:shipping_address], @order.shipping_address) if data[:shipping_address]
        sync_address(data[:billing_address], @order.billing_address) if data[:billing_address]
        sync_payment(data[:payment]) if data[:payment]

        unless data[:items].nil?
          data[:items].each do |item|
            sync_magento_line_item_to_local(item)
          end
        end

        unless data[:status_history].nil?
          data[:status_history].each do |status|
            sync_magento_order_status_to_local(status)
          end
        end

        render nothing: true
      end

      private

      def sync_address(source, address = nil)
        address = Address.new if address.nil?
        address.addressable = @order
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
        address.is_billing = (source[:address_type] == 'billing')
        address.is_shipping = (source[:address_type] == 'shipping')
        address.save validate: false

        return address
      end

      def sync_magento_order_status_to_local(source)
        order_status = OrderStatus.where(order: @order, status: source[:status], comment: source[:comment]).first_or_initialize
        order_status.order = @order
        order_status.status = source[:status]
        order_status.is_active = source[:is_active]
        order_status.is_customer_notified = source[:is_customer_notified] == 2 ? nil : source[:is_customer_notified]
        order_status.comment = source[:comment]
        order_status.created_at = source[:created_at]
        order_status.save

        order_status
      end

      def sync_magento_line_item_to_local(source)
        product = Product.find_by(magento_id: source[:product_id])
        line_item = LineItem.where("magento_id = ? OR (itemizable_type = 'Gemgento::Order' AND itemizable_id = ? AND product_id = ?)", source[:item_id], @order.id, product.id).first_or_initialize
        line_item.itemizable = @order
        line_item.magento_id = source[:item_id]
        line_item.quote_item_id = source[:quote_item_id]
        line_item.product = Product.find_by(magento_id: source[:product_id])
        line_item.product_type = source[:product_type]
        line_item.product_options = source[:product_options]
        line_item.weight = source[:weight]
        line_item.is_virtual = source[:is_virtual]
        line_item.sku = source[:sku]
        line_item.name = source[:name]
        line_item.applied_rule_ids = source[:applied_rule_ids]
        line_item.free_shipping = source[:free_shipping]
        line_item.is_qty_decimal = source[:is_qty_decimal]
        line_item.no_discount = source[:no_discount]
        line_item.qty_canceled = source[:qty_canceled]
        line_item.qty_invoiced = source[:qty_invoiced]
        line_item.qty_ordered = source[:qty_ordered]
        line_item.qty_refunded = source[:qty_refunded]
        line_item.qty_shipped = source[:qty_shipped]
        line_item.cost = source[:cost]
        line_item.price = source[:price]
        line_item.base_price = source[:base_price]
        line_item.original_price = source[:original_price]
        line_item.base_original_price = source[:base_original_price]
        line_item.tax_percent = source[:tax_percent]
        line_item.tax_amount = source[:tax_amount]
        line_item.base_tax_amount = source[:base_tax_amount]
        line_item.tax_invoiced = source[:tax_invoiced]
        line_item.base_tax_invoiced = source[:base_tax_invoiced]
        line_item.discount_percent = source[:discount_percent]
        line_item.discount_amount = source[:discount_amount]
        line_item.base_discount_amount = source[:base_discount_amount]
        line_item.discount_invoiced = source[:discount_invoiced]
        line_item.base_discount_invoiced = source[:base_discount_invoiced]
        line_item.amount_refunded = source[:amount_refunded]
        line_item.base_amount_refunded = source[:base_amount_refunded]
        line_item.row_total = source[:row_total]
        line_item.base_row_total = source[:base_row_total]
        line_item.row_invoiced = source[:row_invoiced]
        line_item.base_row_invoiced = source[:base_row_invoiced]
        line_item.row_weight = source[:row_weight]
        line_item.base_tax_before_discount = source[:base_tax_before_discount]
        line_item.tax_before_discount = source[:tax_before_discount]
        line_item.weee_tax_applied = source[:weee_tax_applied]
        line_item.weee_tax_applied_amount = source[:weee_tax_applied_amount]
        line_item.weee_tax_applied_row_amount = source[:weee_tax_applied_row_amount]
        line_item.base_weee_tax_applied_amount = source[:base_weee_tax_applied_amount]
        line_item.base_weee_tax_applied_row_amount = source[:base_weee_tax_applied_row_amount]
        line_item.weee_tax_disposition = source[:weee_tax_disposition]
        line_item.weee_tax_row_disposition = source[:weee_tax_row_disposition]
        line_item.base_weee_tax_disposition = source[:base_weee_tax_disposition]
        line_item.base_weee_tax_row_disposition = source[:base_weee_tax_row_disposition]
        line_item.save

        unless source[:gift_message_id].nil?
          gift_message = API::SOAP::EnterpriseGiftMessage::GiftMessage.sync_magento_to_local(source[:gift_message])
          line_item.gift_message = gift_message
          line_item.save
        end

        line_item
      end

      def sync_payment(source)
        payment = Gemgento::Payment.find_or_initialize_by(magento_id: source[:parent_id])
        payment.payable = @order
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
        payment.save
      end

    end
  end
end