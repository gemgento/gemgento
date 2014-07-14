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
      store = store(order)
      shipping_address = order.shipping_address
      billing_address = order.billing_address
      totals = totals(order)
      line_items = order.line_items

      [
          order.order_number, # order_id
          store.code, # website
          order.email, # email
          '', # password
          user_group(user), # group_id
          store.magento_id, # store_id
          'payment_cryozonic_stripe', # payment_method
          'flatrate_flatrate', # shipping_method
          '', # billing_prefix
          billing_address.first_name, # billing_firstname
          '', # billing_middlename
          billing_address.last_name, # billing_lastname
          '', # billing_suffix
          street(billing_address), # billing_street_full
          billing_address.city, # billing_city
          billing_address.province, # billing_region
          billing_address.country, # billing_country
          billing_address.zip, # billing_postcode
          billing_address.phone, # billing_telephone
          billing_address.company, # billing_company
          '', # billing_fax
          '', # shipping_prefix
          shipping_address.first_name, # shipping_firstname
          '', # shipping_middlename
          shipping_address.last_name, # shipping_lastname
          '', # shipping_suffix
          street(shipping_address), # shipping_street_full
          shipping_address.city, # shipping_city
          shipping_address.province, # shipping_region
          shipping_address.country, # shipping_country
          shipping_address.zip, # shipping_postcode
          shipping_address.phone, # shipping_telephone
          shipping_address.company, # shipping_company
          '', # shipping_fax
          store.name, # created_in
          (order.buyer_accepts_marketing ? 1 : 0), # is_subscribed
          (user.nil? ? nil : user.magento_id), # customer_id
          order.created_at, # created_at
          order.updated_at, # updated_at
          totals[:tax], # tax_amount
          totals[:shipping], # shipping_amount
          totals[:discount], # discount_amount
          totals[:subtotal], # subtotal
          totals[:grand], # grand_total
          totals[:paid], # total_paid
          totals[:refunded], # total_refunded
          quantity_ordered(order), # total_qty_ordered
          totals[:canceled], # total_canceled
          totals[:grand], # total_invoiced
          totals[:refunded], # total_online_refunded
          0, # total_offline_refunded
          totals[:tax], # base_tax_amount
          totals[:shipping], # base_shipping_amount
          totals[:discount], # base_discount_amount
          totals[:subtotal], # base_subtotal
          totals[:grand], # base_grand_total
          totals[:paid], # base_total_paid
          totals[:refunded], # base_total_refunded
          quantity_ordered(order), # base_total_qty_ordered
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

    # Retrieve the store related to the order.
    #
    # @param order [ShopifyAPI::Order]
    # @return [Gemgento::Store]
    def self.store(order)
      return Gemgento::Store.first
    end

    # Calculate the various totals for an order.
    #
    # @param [ShopifyAPI::Order]
    # @return [Hash(Double)]
    def self.totals(order)
      totals = {}
      totals[:subtotal] = order.subtotal_price
      totals[:tax] = order.total_tax
      totals[:shipping] = shipping_amount(order)
      totals[:discount] = order.total_discounts
      totals[:grand] = order.total_price
      totals[:refunded] = refund_amount(order)
      totals[:paid] = paid_amount(order)
      totals[:canceled] = canceled_amount(order)

      return totals
    end

    # Get the user group from the provided user.  Default to NOT LOGGED IN.
    #
    # @param user [Gemgento::User, nil]
    # @return [String]
    def self.user_group(user)
      if user.nil?
        return Gemgento::UserGroup.find_by(magento_id: 0).code
      else
        return user.user_group.code
      end
    end

    # Get a formatted street attribute from an address.
    #
    # @param address [ShopifyAPI::ShippingAddress, ShopifyAPI::BillingAddress]
    # @return [String]
    def self.street(address)
      street = address.address1
      street = "#{street}\n#{address.address2}" unless address.address2.blank?

      return street
    end

    # Calculate total shipping cost for shopify order.
    #
    # @param order [ShopifyAPI::Order]
    # @return [Double]
    def self.shipping_amount(order)
      total = 0.0

      order.shipping_lines.each do |shipping_line|
        total = total + shipping_line.price
      end

      return total
    end

    # Calculate the total amount refunded.
    #
    # @param order [ShopifyAPI::Order]
    # @return [Double]
    def self.refund_amount(order)
      total = 0.0

      order.refunds.each do |refund|
        refund.transactions.each do |transaction|
          total = total + refund.amount if transaction.kind = 'refund'
        end
      end

      return total
    end

    # Calculate total quantity of ordered items.
    #
    # @param [ShopifyAPI::Order]
    # @return [Double]
    def self.quantity_ordered(order)
      total = 0.0

      order.line_items.each do |line_item|
        total = total + line_item.quantity
      end

      return total
    end

    # Generate a string of line item details for the order.
    #
    # @param line_items [ShopifyAPI::LineItem]
    # @param store [Gemgento::Store]
    def self.products_ordered(line_items, store)
      ordered = []

      line_items.each do |line_item|
        shopify_adapter = Gemgento::Adapter::ShopifyAdapter.find_by(shopify_model_type: 'ShopifyAPI::Variant', shopify_model_id: line_item.variant_id)
        product = shopify_adapter.gemgento_model
        ordered << "#{product.sku}:#{line_item.quantity}:#{product.price}"
      end

      return ordered.join('|')
    end

    # Determine the Magento order status from a Shopify order.
    #
    # @param order [ShopifyAPI::Order]
    # @return [String]
    def self.order_status(order)
      if %w[paid refunded partially_refunded].include? order.financial_status
        if order.fulfillment_status == 'shipped'
          return 'complete'
        elsif %w[refunded partially_refunded].include? order.financial_status
          return 'complete'
        else
          return 'pending'
        end
      elsif order.financial_status == 'pending'
        return 'pending'
      elsif order.financial_status == 'voided'
        return 'canceled'
      else
        return 'complete'
      end
    end

  end
end