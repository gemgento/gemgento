require 'csv'

module Gemgento::Adapter::Sellect
  class Order < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym) if Gemgento::Config[:sellect]

    def self.create_csv(options = {})
      self.table_name = 'sellect_orders'

      CSV.generate(options) do |csv|
        csv << order_export_headers

        get_orders.each do |order|
          csv << order_row(order)
        end
      end
    end

    def self.order_export_headers
      #TODO: set order export headers
    end

    def self.order_row(order)
      #TODO: generate order row data
    end
  end
end
