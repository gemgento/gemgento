namespace :gemgento do
  namespace :sync do
    task :missing_sellect_order_information => :environment do

      Gemgento::Order.placed.each do |order|
        sellect_order = Gemgento::Adapter::SellectAdapter.query('sellect_orders').find_by(number: order.increment_id)
        next if sellect_order.nil?

        payment = Gemgento::Adapter::Sellect::Order.payment(sellect_order.id)
        totals = Gemgento::Adapter::Sellect::Order.totals(sellect_order, payment)

        magento_order = Gemgento::MagentoDB.query('sales_flat_order').find_by(increment_id: order.increment_id)
        next if magento_order.nil?

        magento_order.total_refunded = totals[:refunded]
        magento_order.total_online_refunded = totals[:refunded]
        magento_order.base_total_refunded = totals[:refunded]
        magento_order.base_total_online_refunded = totals[:refunded]
        magento_order.subtotal_refunded = totals[:refunded]
        magento_order.base_subtotal_refunded = totals[:base_subtotal_refunded]

        magento_order.total_paid = totals[:paid]
        magento_order.base_total_paid = totals[:paid]

        magento_order.total_canceled = totals[:canceled]
        magento_order.base_total_canceled = totals[:canceled]
        magento_order.subtotal_canceled = totals[:canceled]
        magento_order.base_subtotal_canceled = totals[:canceled]

        magento_order.shipping_amount = totals[:shipping]
        magento_order.base_shipping_amount = totals[:shipping]
        magento_order.shipping_invoiced = totals[:shipping]
        magento_order.base_shipping_invoiced = totals[:shipping]

        magento_order.save
      end

    end
  end
end