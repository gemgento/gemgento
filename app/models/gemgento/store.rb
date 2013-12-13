module Gemgento
  class Store < ActiveRecord::Base
    has_many :users

    has_and_belongs_to_many :products, -> { distinct }, join_table: 'gemgento_products_stores', class_name: 'Product'

    def self.current
      return Store.find_by(code: 'default')
    end

  end
end