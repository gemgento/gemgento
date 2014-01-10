module Gemgento::Adapter
  class SellectAdapter < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym) if Gemgento::Config[:sellect]

    def self.query(table_name)
      self.table_name = table_name
      return self
    end

    def self.import(store, currency)
      Gemgento::Store.current = store
      Gemgento::Adapter::Sellect::Product.import(currency)
    end

  end
end