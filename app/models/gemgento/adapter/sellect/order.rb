module Gemgento::Adapter::Sellect
  class Order < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym)

    def self.import
      self.table_name = 'sellect_orders'
    end
  end
end
