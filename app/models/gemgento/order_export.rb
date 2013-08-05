require 'csv'

module Gemgento
  class OrderExport

    def initialize(start_datetime, order_attributes, product_attributes, item_attributes, delimiter, path)
      @order_attributes = order_attributes
      @product_attributes = product_attributes
      @item_attributes = item_attributes
      @delimiter = delimiter
      @start_datetime = start_datetime
      @file_name = "orders-#{Time.now.strftime("%Y%m%d")}"
      @path = path
      @report = []
    end

    def generate
      Order.where('state != ? AND created_at >= ?', 'cart', @start_datetime).each do |order|
        order.order_items.each do |order_item|
          line_item_details = []

          @order_attributes.each do |attribute|
            line_item_details << requested_value(order, attribute)
          end

          @product_attributes.each do |attribute|
            line_item_details << order_item.product.attribute_value(attribute)
          end

          @item_attributes.each do |attribute|
            line_item_details << requested_value(order_item, attribute)
          end

          @report << line_item_details
        end
      end

      return @report
    end

    def export_csv
      File.open(@path + @file_name + '.csv', 'w+') { |f| f << @report.map { |row| row.join(',') }.join("\n") }

      return @path + @file_name + '.csv'
    end

    private

    def requested_value(object, attribute)
      if object.column_for_attribute(attribute.to_sym).type != :datetime
        return object.send(attribute)
      else
        return object.send(attribute).strftime("%Y%m%d%H%M%S")
      end
    end

  end
end
