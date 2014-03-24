namespace :gemgento do
  namespace :sync do
    task :missing_sellect_order_information => :environment do

      Gemgento::Order.placed.each do |order|
        sellect_order = Gemgento::Adapter::SellectAdapter.query('sellect_orders').find_by(number: order.increment_id)
        next if sellect_order.nil?

        payment = Gemgento::Adapter::Sellect::Order.payment(sellect_order.id)
        totals = Gemgento::Adapter::Sellect::Order.totals(sellect_order, payment)


        # Order Data
        magento_order = Gemgento::MagentoDB.query('sales_flat_order').find_by(increment_id: order.increment_id)

        if magento_order.nil?
          "ERROR: Could not find Magento order for Order ##{order.increment_id}"
          next
        end

        # refunded totals
        magento_order.total_refunded = totals[:refunded]
        magento_order.total_online_refunded = totals[:refunded]
        magento_order.base_total_refunded = totals[:refunded]
        magento_order.base_total_online_refunded = totals[:refunded]
        magento_order.subtotal_refunded = totals[:refunded]
        magento_order.base_subtotal_refunded = totals[:refunded]

        # paid totals
        magento_order.total_paid = totals[:paid]
        magento_order.base_total_paid = totals[:paid]
        magento_order.base_total_invoiced = totals[:paid]
        magento_order.total_invoiced = totals[:paid]

        # canceled totals
        magento_order.total_canceled = totals[:canceled]
        magento_order.base_total_canceled = totals[:canceled]
        magento_order.subtotal_canceled = totals[:canceled]
        magento_order.base_subtotal_canceled = totals[:canceled]

        # shipping totals
        magento_order.shipping_amount = totals[:shipping]
        magento_order.base_shipping_amount = totals[:shipping]
        magento_order.shipping_invoiced = totals[:shipping]
        magento_order.base_shipping_invoiced = totals[:shipping]

        # grand totals
        magento_order.base_grand_total = totals[:grand]
        magento_order.grand_total = totals[:grand]

        # subtotals
        magento_order.base_subtotal = totals[:subtotal]
        magento_order.base_subtotal_invoiced = totals[:subtotal]
        magento_order.subtotal = totals[:subtotal]
        magento_order.subtotal_invoiced = totals[:subtotal]

        # done
        magento_order.save
        puts "Update Order ##{order.increment_id}: #{totals}"


        # Payment Data
        magento_payment = Gemgento::MagentoDB.query('sales_flat_order_payment').find_by(parent_id: magento_order.id)

        if magento_payment.nil?
          "ERROR: Could not find Magento payment for Order ##{order.increment_id}"
          next
        end

        # refunded totals
        magento_payment.amount_refunded = totals[:refunded]
        magento_payment.base_amount_refunded_online = totals[:refunded]
        magento_payment.base_amount_refunded = totals[:refunded]

        # paid totals
        magento_payment.base_amount_paid = totals[:paid]
        magento_payment.base_amount_authorized = totals[:paid]
        magento_payment.base_amount_paid_online = totals[:paid]
        magento_payment.amount_paid = totals[:paid]
        magento_payment.amount_authorized = totals[:paid]

        # canceled totals
        magento_payment.amount_canceled = totals[:canceled]
        magento_payment.base_amount_canceled = totals[:canceled]

        # shipping totals
        magento_payment.base_shipping_captured = totals[:shipping]
        magento_payment.shipping_captured = totals[:shipping]
        magento_payment.base_shipping_amount = totals[:shipping]
        magento_payment.shipping_amount = totals[:shipping]

        # grand totals
        magento_payment.base_amount_ordered = totals[:grand]
        magento_payment.amount_ordered = totals[:grand]

        # done
        magento_payment.save


        # Invoice Data
        magento_invoice = Gemgento::MagentoDB.query('sales_flat_invoice').find_by(order_id: magento_order.id)

        if magento_invoice.nil?
          "ERROR: Could not find Magento invoice for Order ##{order.increment_id}"
          next
        end

        # refunded totals
        magento_invoice.base_total_refunded = totals[:refunded]

        # shipping totals
        magento_invoice.shipping_amount = totals[:shipping]
        magento_invoice.base_shipping_amount = totals[:shipping]

        # tax totals
        magento_invoice.tax_amount = totals[:tax]
        magento_invoice.base_tax_amount = totals[:tax]

        # grand totals
        magento_invoice.base_grand_total = totals[:grand]
        magento_invoice.grand_total = totals[:grand]

        # subtotals
        magento_invoice.base_subtotal = totals[:subtotal]
        magento_invoice.subtotal = totals[:subtotal]
        magento_invoice.subtotal_incl_tax = totals[:subtotal] + totals[:tax]
        magento_invoice.base_subtotal_incl_tax = totals[:subtotal] + totals[:tax]

        # currency conversion rates
        magento_invoice.store_to_base_rate = 1
        magento_invoice.base_to_global_rate = 1

        # done
        magento_invoice.save
        
        puts "Update Order Payment ##{order.increment_id}: #{totals}"
      end

    end
  end
end