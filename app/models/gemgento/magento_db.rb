module Gemgento

  # @author Gemgento LLC
  class MagentoDB < ActiveRecord::Base

    # Associate configurable and simple Products by reading directly from the Magento table with the association data.
    #
    # @param configurable_product [Gemgento::Product]
    # @return [Array(Gemgento::Product)]
    def self.associated_simple_products(configurable_product)
      establish_connection("magento_#{Rails.env}".to_sym)

      self.table_name = "#{Config[:magento][:table_prefix]}catalog_product_super_link"
      simple_products = []

      self.where('parent_id = ?', configurable_product.magento_id).each do |association|
        simple_product = Product.where(magento_id: association.product_id).first
        simple_products << simple_product unless simple_product.nil?
      end

      simple_products
    end

    # Query the Magento database using ActiveRecord.
    #
    # @param table_name [String]
    # @return [ActiveRecord::Result]
    def self.query(table_name)
      establish_connection("magento_#{Rails.env}".to_sym)

      self.table_name = Config[:magento][:table_prefix] + table_name
      return self
    end
  end
end