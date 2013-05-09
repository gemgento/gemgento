module Gemgento
  class ProductAttributeSet < ActiveRecord::Base
    has_many :product_attributes
    has_many :products
    after_save :sync_local_to_magento

    def self.index
      if ProductAttributeSet.find(:all).size == 0
        fetch_all
      end

      ProductAttributeSet.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:catalog_product_attribute_set_list)

      if response[:result][:item].is_a? Array
        response[:result][:item].each do |product_attribute_set|
          sync_magento_to_local(product_attribute_set)
        end
      else
        sync_magento_to_local(response[:result][:item])
      end

    end

    private

    # Save Magento product attribute set to local
    def self.sync_magento_to_local(source)
      product_attribute_set = ProductAttributeSet.find_or_initialize_by_magento_id(source[:set_id])
      product_attribute_set.magento_id = source[:set_id]
      product_attribute_set.name = source[:name]
      product_attribute_set.sync_needed = false
      product_attribute_set.save

      Gemgento::ProductAttribute.fetch_all(product_attribute_set)
      Gemgento::AssetType.fetch_all(product_attribute_set)
    end

    # Push local product attribute set changes to Magento
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
          create_magento
        else
          update_magento
        end

        self.sync_needed = false
        self.save
      end
    end

    # Create a new product attribute set in Magento
    def create_magento
      # TODO: create a new product attribute set on Magento
    end

    # Update existing Magento product attribute set
    def update_magento
      # TODO: update a product attribute set on Magento
    end
  end
end