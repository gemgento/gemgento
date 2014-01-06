module Gemgento::Adapter
  class Sellect < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym)

    def self.query(table_name)
      self.table_name = table_name
      return self
    end

    def self.import
      Gemgento::Adapter::Sellect::Product.import
    end

  end
end