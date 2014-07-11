require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Order

    # Export all shopify orders to a CSV.
    #
    # @return [Void]
    def self.export
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url
      page = 1
      shopify_orders = ShopifyAPI::Order.where(limit: 250, page: page)

      CSV.open('orders.csv', 'wb') do |csv|
        csv << order_export_headers
        while shopify_orders.any?
          shopify_orders.each do |shopify_order|
            csv << order_row(shopify_order)
          end

          page = page + 1
          shopify_orders = ShopifyAPI::Order.where(limit: 250, page: page)
        end
      end
    end

    # Generate CSV headers for an order export.
    #
    # @return [Array(String)]
    def self.order_export_headers
      %w[
          order_id website email password group_id store_id payment_method shipping_method
          billing_prefix billing_firstname billing_middlename billing_lastname billing_suffix
          billing_street_full billing_city billing_region billing_country billing_postcode
          billing_telephone billing_company billing_fax shipping_prefix shipping_firstname
          shipping_middlename shipping_lastname shipping_suffix shipping_street_full shipping_city
          shipping_region shipping_country shipping_postcode shipping_telephone shipping_company
          shipping_fax created_in is_subscribed customer_id created_at updated_at tax_amount
          shipping_amount discount_amount subtotal grand_total total_paid total_refunded
          total_qty_ordered total_canceled total_invoiced total_online_refunded total_offline_refunded
          base_tax_amount base_shipping_amount base_discount_amount base_subtotal base_grand_total
          base_total_paid base_total_refunded base_total_qty_ordered base_total_canceled base_total_invoiced
          base_total_online_refunded base_total_offline_refunded subtotal_refunded subtotal_canceled
          discount_refunded discount_invoiced tax_refunded tax_canceled shipping_refunded shipping_canceled
          base_subtotal_refunded base_subtotal_canceled base_discount_refunded base_discount_canceled
          base_discount_invoiced base_tax_refunded base_tax_canceled base_shipping_refunded
          base_shipping_canceled subtotal_invoiced tax_invoiced shipping_invoiced base_subtotal_invoiced
          base_tax_invoiced base_shipping_invoiced shipping_tax_amount base_shipping_tax_amount
          shipping_tax_refunded base_shipping_tax_refunded products_ordered order_status
      ]
    end

    # Create a row for the given order.
    #
    # @param order [ShopifyAPI::Order]
    # @return [Array(String)]
    def self.order_row(order)
      user = Gemgento::User.find_by(email: order.email)
      store = store(order.zone_member_id)
      shipping_addres = address(order.ship_address_id)
      billing_address = address(order.bill_address_id)
      payment = payment(order.id)
      totals = totals(order, payment)
      line_items = line_items(order.id).reload

      [
          order.number.gsub('R', ''), # order_id
          store.code, # website
          email(order.email), # email
          '', # password
          user_group(user), # group_id
          store.magento_id, # store_id
          'globalcollect_cc_merchant', # payment_method
          'flatrate_flatrate', # shipping_method
          '', # billing_prefix
          billing_address.firstname, # billing_firstname
          '', # billing_middlename
          billing_address.lastname, # billing_lastname
          '', # billing_suffix
          street(billing_address), # billing_street_full
          billing_address.city, # billing_city
          state(billing_address), # billing_region
          country(billing_address), # billing_country
          billing_address.zipcode, # billing_postcode
          billing_address.phone, # billing_telephone
          '', # billing_company
          '', # billing_fax
          '', # shipping_prefix
          shipping_addres.firstname, # shipping_firstname
          '', # shipping_middlename
          shipping_addres.lastname, # shipping_lastname
          '', # shipping_suffix
          street(shipping_addres), # shipping_street_full
          shipping_addres.city, # shipping_city
          state(shipping_addres), # shipping_region
          country(shipping_addres), # shipping_country
          shipping_addres.zipcode, # shipping_postcode
          shipping_addres.phone, # shipping_telephone
          '', # shipping_company
          '', # shipping_fax
          store.name, # created_in
          0, # is_subscribed
          nil, # customer_id
          order.created_at, # created_at
          order.updated_at, # updated_at
          totals[:tax], # tax_amount
          totals[:shipping], # shipping_amount
          0, # discount_amount
          totals[:subtotal], # subtotal
          totals[:grand], # grand_total
          totals[:paid], # total_paid
          totals[:refunded], # total_refunded
          0, # total_qty_ordered
          totals[:canceled], # total_canceled
          totals[:grand], # total_invoiced
          totals[:refunded], # total_online_refunded
          0, # total_offline_refunded
          totals[:tax], # base_tax_amount
          totals[:shipping], # base_shipping_amount
          0, # base_discount_amount
          totals[:subtotal], # base_subtotal
          totals[:grand], # base_grand_total
          totals[:paid], # base_total_paid
          totals[:refunded], # base_total_refunded
          0, # base_total_qty_ordered
          totals[:canceled], # base_total_canceled
          totals[:grand], # base_total_invoiced
          totals[:refunded], # base_total_online_refunded
          0, # base_total_offline_refunded
          totals[:refunded], # subtotal_refunded
          totals[:canceled], # subtotal_canceled
          0, # discount_refunded
          0, # discount_invoiced
          0, # tax_refunded
          0, # tax_canceled
          0, # shipping_refunded
          0, # shipping_canceled
          totals[:refunded], # base_subtotal_refunded
          totals[:canceled], # base_subtotal_canceled
          0, # base_discount_refunded
          0, # base_discount_canceled
          0, # base_discount_invoiced
          0, # base_tax_refunded
          0, # base_tax_canceled
          0, # base_shipping_refunded
          0, # base_shipping_canceled
          totals[:subtotal], # subtotal_invoiced
          totals[:tax], # tax_invoiced
          totals[:shipping], # shipping_invoiced
          totals[:subtotal], # base_subtotal_invoiced
          totals[:tax], # base_tax_invoiced
          totals[:shipping], # base_shipping_invoiced
          0, # shipping_tax_amount
          0, # base_shipping_tax_amount
          0, # shipping_tax_refunded
          0, # base_shipping_tax_refunded
          products_ordered(line_items, store), # products_ordered
          order_status(order.state) # order_status
      ]
    end

  end
end