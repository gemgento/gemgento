module Gemgento
  class OrderItem < ActiveRecord::Base
    belongs_to  :order
    belongs_to  :product
    has_one     :gift_message

    def sync_magento_to_local(source, order)
      order_item = OrderItem.find_by(magento_id: source[:item_id], order: order)
      order_item.order = order
      order_item.magento_id = source[:item_id]
      order_item.quote_item_id = source[:quote_item_id]
      order_item.product = Product.find_by(magento_id: source[:product_id])
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

      order_item

      unless source[:gift_message_id].nil?
        gift_message = GiftMessage.sync_magento_to_local(source[:gift_message])
        order_item.gift_message = gift_message
        order_item.save
      end
    end
  end
end