require 'csv'

module Gemgento::Adapter::Sellect
  class Order < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym) if Gemgento::Config[:sellect]

    def self.export_to_csv
      CSV.open("orders.csv", "wb") do |csv|
        csv << order_export_headers
        completed_orders.each_with_index do |order, index|
          puts "Working on row #{index}"
          csv << order_row(order)
        end
      end
    end

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

    def self.completed_orders
      self.table_name = 'sellect_orders'

      return self.where(state: %w[complete returned challenged challenged_canceled]).order('created_at ASC')
    end

    def self.order_row(order)
      user = Gemgento::User.find_by(email: order.email)
      store = store(order.zone_member_id)
      shipping_addres = address(order.ship_address_id)
      billing_address = address(order.bill_address_id)
      payment = payment(order.id)
      shipment = shipment(order.id)
      totals = totals(order, payment)
      line_items = line_items(order.id).reload

      [
        order.number.gsub('R', ''),   # order_id
        store.code,                   # website
        email(order.email),           # email
        '',                           # password
        user_group(user),             # group_id
        store.magento_id,             # store_id
        'globalcollect_cc_merchant',  # payment_method
        'flatrate_flatrate',          # shipping_method
        '',                           # billing_prefix
        billing_address.firstname,    # billing_firstname
        '',                           # billing_middlename
        billing_address.lastname,     # billing_lastname
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
        store.name,                   # created_in
        0,                            # is_subscribed
        nil,                          # customer_id
        order.created_at,             # created_at
        order.updated_at,             # updated_at
        totals[:tax],                 # tax_amount
        totals[:shipping],            # shipping_amount
        0,                            # discount_amount
        totals[:subtotal],            # subtotal
        totals[:grand],               # grand_total
        totals[:paid],                # total_paid
        totals[:refunded],            # total_refunded
        0,                            # total_qty_ordered
        totals[:canceled],            # total_canceled
        totals[:grand],               # total_invoiced
        totals[:refunded],            # total_online_refunded
        0,                            # total_offline_refunded
        totals[:tax],                 # base_tax_amount
        totals[:shipping],            # base_shipping_amount
        0,                            # base_discount_amount
        totals[:subtotal],            # base_subtotal
        totals[:grand],               # base_grand_total
        totals[:paid],                # base_total_paid
        totals[:refunded],            # base_total_refunded
        0,                            # base_total_qty_ordered
        totals[:canceled],            # base_total_canceled
        totals[:grand],               # base_total_invoiced
        totals[:refunded],            # base_total_online_refunded
        0,                            # base_total_offline_refunded
        totals[:refunded],            # subtotal_refunded
        totals[:canceled],            # subtotal_canceled
        0,                            # discount_refunded
        0,                            # discount_invoiced
        0,                            # tax_refunded
        0,                            # tax_canceled
        0,                            # shipping_refunded
        0,                            # shipping_canceled
        totals[:refunded],            # base_subtotal_refunded
        totals[:canceled],            # base_subtotal_canceled
        0,                            # base_discount_refunded
        0,                            # base_discount_canceled
        0,                            # base_discount_invoiced
        0,                            # base_tax_refunded
        0,                            # base_tax_canceled
        0,                            # base_shipping_refunded
        0,                            # base_shipping_canceled
        totals[:subtotal],            # subtotal_invoiced
        totals[:tax],                 # tax_invoiced
        totals[:shipping],            # shipping_invoiced
        totals[:subtotal],            # base_subtotal_invoiced
        totals[:tax],                 # base_tax_invoiced
        totals[:shipping],            # base_shipping_invoiced
        0,                            # shipping_tax_amount
        0,                            # base_shipping_tax_amount
        0,                            # shipping_tax_refunded
        0,                            # base_shipping_tax_refunded
        products_ordered(line_items), # products_ordered
        order_status(order.state)     # order_status
      ]
    end

    def self.store(zone_member_id)
      self.table_name = 'sellect_zone_members'
      zone_member = self.find(zone_member_id)

      case zone_member.currency
        when 'eur'
          store = Gemgento::Store.find_by(code: 'eu')
        when 'gbp'
          store = Gemgento::Store.find_by(code: 'uk')
        when 'usd'
          store = Gemgento::Store.find_by(code: 'us')
        else
          store = Gemgento::Store.first
      end

      return store
    end

    def self.address(address_id)
      self.table_name = 'sellect_addresses'
      address = self.find_by(id: address_id)

      if address.nil?
        return address_not_provided
      else
        return address
      end
    end

    def self.address_not_provided
      self.table_name = 'sellect_addresses'
      address = self.new
      address.firstname = 'NOT PROVIDED'
      address.lastname = 'NOT PROVIDED'
      address.address1 = 'NOT PROVIDED'
      address.city = 'NOT PROVIDED'
      address.zipcode = 'NOT PROVIDED'
      address.phone = 'NOT PROVIDED'

      return address
    end

    def self.payment(order_id)
      self.table_name = 'sellect_payments'

      return self.find_by(order_id: order_id)
    end

    def self.shipment(order_id)
      self.table_name = 'sellect_shipments'

      return self.find_by(order_id: order_id)
    end

    def self.totals(order, payment)
      totals = {}
      totals[:grand] = order.total.to_f
      totals[:shipping] = shipping_cost(order)
      totals[:tax] = tax(order)
      totals[:subtotal] = totals[:grand] - totals[:shipping] - totals[:tax]
      totals[:paid] = order.payment_total
      totals[:refunded] = total_refunded(order)
      totals[:canceled] = total_canceled(order)

      return totals
    end

    def self.shipping_cost(order)
      self.inheritance_column = :_type_disabled
      self.table_name = 'sellect_adjustments'
      cost = self.find_by(
          source_type: 'Sellect::Order',
          source_id: order.id,
          originator_type: 'Sellect::ShippingMethod'
      )

      if cost.nil?
        return 0
      else
        return cost.amount.to_f
      end
    end

    def self.tax(order)
      self.inheritance_column = :_type_disabled
      self.table_name = 'sellect_adjustments'
      tax = self.find_by(
          source_type: 'Sellect::Order',
          source_id: order.id,
          originator_type: 'Sellect::TaxRate'
      )

      if tax.nil?
        return 0
      else
        return tax.amount.to_f
      end
    end

    def self.subtotal(order)
      self.inheritance_column = :_type_disabled
      self.table_name = 'sellect_adjustments'
      self.find_by(source_type: 'Sellect::Order', source_id: order.id)
    end

    def self.total_refunded(order)
      self.inheritance_column = :_type_disabled
      self.table_name = 'sellect_adjustments'
      refunds = self.where(
          source_type: 'Sellect::Order',
          source_id: order.id,
          originator_type: nil,
          label: 'Refund Credit'
      )

      total = 0
      refunds.each { |r| total+= r.amount.to_f }

      return total
    end

    def self.total_canceled(order)
      if order.state == 'challenged_canceled'
        order.payment_total
      else
        0
      end
    end

    def self.line_items(order_id)
      self.table_name = 'sellect_line_items'

      return self.where(order_id: order_id)
    end

    def self.email(email)
      if email.nil? || email == ''
        return 'unknown@sellect.com'
      else
        return email
      end
    end

    def self.user_group(user)
      if user.nil? || user.id.nil?
        return Gemgento::UserGroup.find_by(magento_id: 0).code
      else
        return user.user_group.code
      end
    end

    def self.street(address)
      street = address.address1.nil? ? 'NOT PROVIDED' : address.address1

      if !address.address2.nil? && address.address2 != ''
        street+= "\n" + address.address2
      end

      return street
    end

    def self.state(address)
      self.table_name = 'sellect_states'

      if address.state_id.nil?
        return nil
      else
        return self.find(address.state_id).name
      end
    end

    def self.country(address)
      self.table_name = 'sellect_countries'

      if address.country_id.nil?
        return nil
      else
        return self.find(address.country_id).iso
      end
    end

    def self.user_id(user)
      if user.nil?
        return nil
      else
        return user.magento_id
      end
    end

    def self.quantity(line_items)
      quantity = 0

      line_items.each { |li| quantity+= li.quantity }

      return quantity
    end

    def self.product(variant_id)
      self.table_name = 'sellect_variants'
      variant = self.find_by(id: variant_id)
      return nil if variant.nil?

      upc = Gemgento::ProductAttribute.find_by(code: 'upc')

      return Gemgento::Product.where(magento_type: 'simple').filter({ attribute: upc, value: variant.upc }).first
    end

    def self.products_ordered(line_items)
      ordered = []

      line_items.each do |li|
        p = product(li.variant_id)
        next if p.nil?
        ordered << "#{p.sku}:#{li.quantity}:#{p.price}"
      end

      return ordered.join('|')
    end

    def self.order_status(state)
      case state
        when 'complete'
          'complete'
        when 'returned'
          'complete'
        when 'challenged'
          'fraud'
        when 'challenged_canceled'
          'canceled'
        else
          'complete'
      end
    end

  end
end
