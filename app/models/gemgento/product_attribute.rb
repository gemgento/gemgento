module Gemgento
  class ProductAttribute < ActiveRecord::Base
    belongs_to :product_attribute_set
    has_many :product_attribute_values
    has_many :product_attribute_options
    has_and_belongs_to_many :configurable_products, -> { uniq } , join_table: 'gemgento_configurable_attributes', class_name: 'Product'
    after_save :sync_local_to_magento

    def self.index

    end

  end
end