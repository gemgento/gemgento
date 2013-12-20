module Gemgento
  class Store < ActiveRecord::Base
    has_many :orders
    has_many :product_imports
    has_many :product_categories
    has_many :product_attribute_options
    has_many :product_attribute_values
    has_many :users

    has_and_belongs_to_many :products, -> { distinct }, join_table: 'gemgento_stores_products', class_name: 'Product'
    has_and_belongs_to_many :categories, -> { distinct }, join_table: 'gemgento_stores_categories', class_name: 'Category'
    has_and_belongs_to_many :users, ->{ distinct }, join_table: 'gemgento_stores_users', class_name: 'User'

    def self.current
      return Store.find_by(code: 'default')
    end

  end
end