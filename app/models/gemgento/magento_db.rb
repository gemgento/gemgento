module Gemgento
  class MagentoDB < ActiveRecord::Base
    establish_connection(:magento)

    def self.associated_simple_products(configurable_product)
      self.table_name = 'catalog_product_super_link'
      simple_products = []

      self.where('parent_id = ?', configurable_product.magento_id).each do |association|
        simple_products << Gemgento::Product.find_by(magento_id: association.product_id)
      end

      simple_products
    end
  end
end