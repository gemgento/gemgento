module Gemgento
  class OrderExportController < BaseController

    def index
      raise 'No order attributes requested' if params[:order_attributes].nil?
      raise 'No order item product attributes requested' if params[:order_item_product_attributes].nil?
      raise 'No order item attributes requested' if params[:order_item_attributes].nil?

      @order_export = []
      order_attributes = params[:order_attributes].split(',')
      order_item_product_attributes = params[:order_item_product_attributes].split(',')
      order_item_attributes = params[:order_item_attributes].split(',')

      Gemgento::Order.where('state != ?', 'cart').each do |order|
        details = []

        order.order_items.each do |order_item|
          details = []

          order_attributes.each do |attribute|
            if Gemgento::Order.columns_hash[attribute].type != :datetime
              details << order.send(attribute)
            else
              details << order.send(attribute).strftime("%Y%m%d%H%M%S")
            end
          end

          order_item_product_attributes.each do |attribute|
            details << order_item.product.attribute_value(attribute)
          end

          order_item_attributes.each do |attribute|
            if Gemgento::OrderItem.columns_hash[attribute].type != :datetime
              details << order_item.send(attribute)
            else
              details << order.send(attribute).strftime("%Y%m%d%H%M%S")
            end
          end
        end

        @order_export << details.join(',')
      end
    end
  end
end