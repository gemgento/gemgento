require 'csv'

module Gemgento::Adapter::Sellect
  class Order < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym) if Gemgento::Config[:sellect]

    def self.create_csv(options = {})


      CSV.generate(options) do |csv|
        csv << order_export_headers

        completed_orders.each do |order|
          csv << order_row(order)
        end
      end
    end

    def self.order_export_headers
      %w[
          order_id,website,email,password,group_id,store_id,payment_method,shipping_method,
          billing_prefix,billing_firstname,billing_middlename,billing_lastname,billing_suffix,
          billing_street_full,billing_city,billing_region,billing_country,billing_postcode,
          billing_telephone,billing_company,billing_fax,shipping_prefix,shipping_firstname,
          shipping_middlename,shipping_lastname,shipping_suffix,shipping_street_full,shipping_city,
          shipping_region,shipping_country,shipping_postcode,shipping_telephone,shipping_company,
          shipping_fax,created_in,is_subscribed,customer_id,created_at,updated_at,tax_amount,
          shipping_amount,discount_amount,subtotal,grand_total,total_paid,total_refunded,
          total_qty_ordered,total_canceled,total_invoiced,total_online_refunded,total_offline_refunded,
          base_tax_amount,base_shipping_amount,base_discount_amount,base_subtotal,base_grand_total,
          base_total_paid,base_total_refunded,base_total_qty_ordered,base_total_canceled,base_total_invoiced,
          base_total_online_refunded,base_total_offline_refunded,subtotal_refunded,subtotal_canceled,
          discount_refunded,discount_invoiced,tax_refunded,tax_canceled,shipping_refunded,shipping_canceled,
          base_subtotal_refunded,base_subtotal_canceled,base_discount_refunded,base_discount_canceled,
          base_discount_invoiced,base_tax_refunded,base_tax_canceled,base_shipping_refunded,
          base_shipping_canceled,subtotal_invoiced,tax_invoiced,shipping_invoiced,base_subtotal_invoiced,
          base_tax_invoiced,base_shipping_invoiced,shipping_tax_amount,base_shipping_tax_amount,
          shipping_tax_refunded,base_shipping_tax_refunded,products_ordered,order_status
      ]
    end

    def self.completed_orders
      self.table_name = 'sellect_orders'

      return self.where('state = ?', 'complete').order('created_at ASC')
    end

    def self.order_row(order)
      user = Gemgento::User.find_by(email: 'email')
      store = order_store(order)

      [
        order.number,                 # order_id
        store.code,                   # website
        order.email,                  # email
        '',                           # password
        user.user_group.code,         # group_id
        store.magento_id,             # store_id
        'globalcollect_cc_merchant',  # payment_method
        '',                           # shipping_method
        '',                           # billing_prefix
        '',                           # billing_firstname
        '',                           # billing_middlename
        '',                           # billing_lastname
        '',                           # billing_suffix
        '',                           # billing_street_full
        '',                           # billing_city
        '',                           # billing_region
        '',                           # billing_country
        '',                           # billing_postcode
        '',                           # billing_telephone
        '',                           # billing_company
        '',                           # billing_fax
        '',                           # shipping_prefix
        '',                           # shipping_firstname
        '',                           # shipping_middlename
        '',                           # shipping_lastname
        '',                           # shipping_suffix
        '',                           # shipping_street_full
        '',                           # shipping_city
        '',                           # shipping_region
        '',                           # shipping_country
        '',                           # shipping_postcode
        '',                           # shipping_telephone
        '',                           # shipping_company
        '',                           # shipping_fax
        '',                           # created_in
        '',                           # is_subscribed
        '',                           # customer_id
        '',                           # created_at
        '',                           # updated_at
        '',                           # tax_amount
        '',                           # shipping_amount
        '',                           # discount_amount
        '',                           # subtotal
        '',                           # grand_total
        '',                           # total_paid
        '',                           # total_refunded
        '',                           # total_qty_ordered
        '',                           # total_canceled
        '',                           # total_invoiced
        '',                           # total_online_refunded
        '',                           # total_offline_refunded
        '',                           # base_tax_amount
        '',                           # base_shipping_amount
        '',                           # base_discount_amount
        '',                           # base_subtotal
        '',                           # base_grand_total
        '',                           # base_total_paid
        '',                           # base_total_refunded
        '',                           # base_total_qty_ordered
        '',                           # base_total_canceled
        '',                           # base_total_invoiced
        '',                           # base_total_online_refunded
        '',                           # base_total_offline_refunded
        '',                           # subtotal_refunded
        '',                           # subtotal_canceled
        '',                           # discount_refunded
        '',                           # discount_invoiced
        '',                           # tax_refunded
        '',                           # tax_canceled
        '',                           # shipping_refunded
        '',                           # shipping_canceled
        '',                           # base_subtotal_refunded
        '',                           # base_subtotal_canceled
        '',                           # base_discount_refunded
        '',                           # base_discount_canceled
        '',                           # base_discount_invoiced
        '',                           # base_tax_refunded
        '',                           # base_tax_canceled
        '',                           # base_shipping_refunded
        '',                           # base_shipping_canceled
        '',                           # subtotal_invoiced
        '',                           # tax_invoiced
        '',                           # shipping_invoiced
        '',                           # base_subtotal_invoiced
        '',                           # base_tax_invoiced
        '',                           # base_shipping_invoiced
        '',                           # shipping_tax_amount
        '',                           # base_shipping_tax_amount
        '',                           # shipping_tax_refunded
        '',                           # base_shipping_tax_refunded
        '',                           # products_ordered
        ''                           # order_status
      ]
    end

    def self.website(order)
      # TODO: return the corresponding Mangento website code
    end
  end
end
