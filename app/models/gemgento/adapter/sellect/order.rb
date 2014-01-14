require 'csv'

module Gemgento::Adapter::Sellect
  class Order < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym) if Gemgento::Config[:sellect]

    def self.export_to_csv(options = {})
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
      store = store(order)
      shipping_addres = address(order.ship_address_id)
      billing_address = address(order.bill_address_id)
      payment = payment(order)
      shipment = shipment(order)
      line_items = line_itmes(order)

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
        billing_address.firstname,    # billing_firstname
        '',                           # billing_middlename
        billing_address.lasttname,    # billing_lastname
        '',                           # billing_suffix
        street(billing_address),      # billing_street_full
        billing_address.city,         # billing_city
        state(billing_address),       # billing_region
        country(billing_address),     # billing_country
        billing_address.zipcode,      # billing_postcode
        billing_address.phone,        # billing_telephone
        '',                           # billing_company
        '',                           # billing_fax
        '',                           # shipping_prefix
        shipping_addres.firstname,    # shipping_firstname
        '',                           # shipping_middlename
        shipping_addres.lastname,     # shipping_lastname
        '',                           # shipping_suffix
        street(shipping_addres),      # shipping_street_full
        shipping_addres.city,         # shipping_city
        state(shipping_addres),       # shipping_region
        country(shipping_addres),     # shipping_country
        shipping_addres.zipcode,      # shipping_postcode
        shipping_addres.phone,        # shipping_telephone
        '',                           # shipping_company
        '',                           # shipping_fax
        '',                           # created_in
        0,                            # is_subscribed
        user.magento_id,              # customer_id
        order.created_at,             # created_at
        order.updated_at,             # updated_at
        0,                            # tax_amount
        '',                           # shipping_amount
        '',                           # discount_amount
        '',                           # subtotal
        order.total,                  # grand_total
        order.payment_total,          # total_paid
        '',                           # total_refunded
        quantity(products),           # total_qty_ordered
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
        products_ordered(line_items), # products_ordered
        'complete'                    # order_status
      ]
    end

    def self.store(order)
      # TODO: return the corresponding Mangento website code
    end

    def self.address(address_id)
      self.table_name = 'sellect_addresses'

      return self.find(address)
    end

    def self.payment(order_id)
      self.table_name = 'sellect_payments'

      return self.find_by(order_id: order_id)
    end

    def self.shipment(order_id)
      self.table_name = 'sellect_shipments'

      return self.find_by(order_id: order_id)
    end

    def self.line_items(order_id)
      self.table_name = 'sellect_line_items'

      return self.where(order_id: order_id)
    end

    def self.street(address)
      street = address.address1

      if address.address2 != ''
        street+= '\n' + address.address2
      end

      return street
    end

    def self.state(address)
      self.table_name = 'sellect_states'

      return self.find(address.state_id).name
    end

    def self.country(address)
      self.table_name = 'sellect_countries'

      return self.find(address.state_id).iso
    end

    def self.quantity(products)
      quantity = 0

      products.each { |p| quantity+= p.quantity }

      return quantity
    end

    def self.product(variant_id)
      self.table_name = 'sellect_variants'
      variant = self.find(variant_id)
      upc = Gemgento::ProductAttribute.find_by(code: 'upc')

      return Gemgento::Product.where(magento_type: 'simple').filter({ attribute: upc, value: variant.upc }).first
    end

    def self.products_ordered(line_items)
      ordered = []

      line_items.each do |li|
        p = product(li.variant_id)
        ordered << "#{p.sku}:#{li.quantity}"
      end

      return ordered
    end

  end
end
