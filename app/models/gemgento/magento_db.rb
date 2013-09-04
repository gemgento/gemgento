module Gemgento
  class MagentoDB < ActiveRecord::Base
    establish_connection("magento_#{Rails.env}".to_sym)

    def self.associated_simple_products(configurable_product)
      self.table_name = 'catalog_product_super_link'
      simple_products = []

      self.where('parent_id = ?', configurable_product.magento_id).each do |association|
        simple_product = Gemgento::Product.where(magento_id: association.product_id).first
        simple_products << simple_product unless simple_product.nil?
      end

      simple_products
    end
  end
end