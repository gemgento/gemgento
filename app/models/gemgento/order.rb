module Gemgento
  class Order < ActiveRecord::Base
    belongs_to :store
    belongs_to :user
    belongs_to :user_group
    belongs_to :shipping_address, foreign_key: 'shipping_address_id', class_name: 'Address'
    belongs_to :billing_address, foreign_key: 'billing_address_id', class_name: 'Address'

    def self.index
      if Order.find(:all).size == 0
        fetch_all
      end

      Order.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:sales_order_list)

      unless response[:result][:item].is_a? Array
        response[:result][:item] = [response[:result][:item]]
      end

      response[:result][:item].each do |order|
        sync_magento_to_local(order)
      end
    end

    private

    # Save Magento order to local
    def self.sync_magento_to_local(source)
      order = Order.find_or_initialize_by(magento_id: source[:order_id])
      order.magento_id = source[:order_id]
      order.store = Store.find_by(magento_id: source[:store_id])
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
      order.billing_address = Address.find_by(magento_id: source[:billing_address_id])
      order.billing_fname = source[:billing_firstname]
      order.billing_lname = source[:billing_lastname]
      order.shipping_address = Address.find_by(source[:shipping_address_id])
      order.shipping_fname = source[:shipping_firstname]
      order.shipping_lname = source[:shipping_lastname]
      order.billing_name = source[:billing_name]
      order.shipping_name = source[:shipping_name]
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
      order.quote_id = source[:quote_id]
      order.is_virtual = source[:is_virtual]
      order.user_group = UserGroup.find_by(magento_id: source[:customer_group_id])
      order.customer_note_notify = source[:customer_note_notify]
      order.customer_is_guest = source[:customer_is_guest]
      order.email_sent = source[:email_sent]
      order.increment_id = source[:increment_id]
      order.gift_message_id = source[:gift_message_id]
      order.gift_message = source[:gift_message]
      order.save
    end
  end
end