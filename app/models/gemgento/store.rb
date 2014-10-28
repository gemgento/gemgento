module Gemgento
  class Store < ActiveRecord::Base
    has_many :inventories
    has_many :orders
    has_many :product_imports
    has_many :product_categories
    has_many :product_attribute_options
    has_many :product_attribute_values
    has_many :users
    has_many :store_tags
    has_many :tags, through: :store_tags

    has_and_belongs_to_many :products, -> { distinct }, join_table: 'gemgento_stores_products', class_name: 'Product'
    has_and_belongs_to_many :categories, -> { distinct }, join_table: 'gemgento_categories_stores', class_name: 'Category'
    has_and_belongs_to_many :users, -> { distinct }, join_table: 'gemgento_stores_users', class_name: 'User'

    cattr_accessor :current

    def self.current
      @@current = Store.first if @@current.nil?
      return @@current
    end

    def self.current=(value)
      @@current = value
    end

  end
end