module Gemgento
  class ProductAttribute < ActiveRecord::Base
    belongs_to :product_attribute_set
    has_many :product_attribute_values
    after_save :sync_local_to_magento

    def self.index
      if ProductAttribute.find(:all).size == 0
        fetch_all
      end

      ProductAttribute.find(:all)
    end

    def self.fetch_all
      Gemgento::ProductAttributeSet.all.each do |product_attribute_set|
        attribute_list_response = Gemgento::Magento.create_call(:catalog_product_attribute_list, {setId: product_attribute_set.magento_id})

        if attribute_list_response[:result][:item].is_a? Array
          attribute_list_response[:result][:item].each do |product_attribute|
             fetch(product_attribute[:attribute_id], product_attribute_set.magento_id)
          end
        else
          fetch(attribute_list_response[:result][:item][:attribute_id], product_attribute_set.magento_id)
        end
      end
    end

    def self.fetch(id, product_attribute_set_id)
      info_response = Gemgento::Magento.create_call(:catalog_product_attribute_info, {attribute: id})
      sync_magento_to_local(info_response[:result], product_attribute_set_id)
    end

    private

    # Save Magento product attribute set to local
    def self.sync_magento_to_local(source, product_attribute_set_id)
      product_attribute = ProductAttribute.find_or_initialize_by_magento_id(source[:attribute_id])
      product_attribute.magento_id = source[:attribute_id]
      product_attribute.product_attribute_set_id = product_attribute_set_id
      product_attribute.code = source[:attribute_code]
      product_attribute.frontend_input = source[:frontend_input]
      product_attribute.scope = source[:scope]
      product_attribute.is_unique = source[:is_unique]
      product_attribute.is_required = source[:is_required]
      product_attribute.is_configurable = source[:is_configurable]
      product_attribute.is_searchable = source[:is_searchable]
      product_attribute.is_visible_in_advanced_search = source[:is_visible_in_advanced_search]
      product_attribute.is_comparable = source[:is_comparable]
      product_attribute.is_used_for_promo_rules = source[:is_used_for_promo_rules]
      product_attribute.is_visible_on_front = source[:is_visible_on_front]
      product_attribute.used_in_product_listing = source[:used_in_product_listing]
      product_attribute.sync_needed = false
      product_attribute.save
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