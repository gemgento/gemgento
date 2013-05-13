module Gemgento
  class ProductAttributeOption < ActiveRecord::Base
    belongs_to :product_attribute

    def self.fetch_all(product_attribute)
        attribute_options_response = Gemgento::Magento.create_call(:catalog_product_attribute_options, {attributeId: product_attribute.magento_id})

        unless attribute_options_response[:result][:item].nil? # check if there are any options returned

          if attribute_options_response[:result][:item].is_a? Array # multiple options returned
            attribute_options_response[:result][:item].each do |attribute_option|
              sync_magento_to_local(attribute_option, product_attribute)
            end
          else # one option returned
            sync_magento_to_local(attribute_options_response[:result][:item], product_attribute)
          end
        end
    end

    private

    # Save Magento product attribute set to local
    def self.sync_magento_to_local(source, parent)
      puts source.inspect
      exit
      label = Gemgento::Magento.enforce_savon_string(source[:label])
      value = Gemgento::Magento.enforce_savon_string(source[:value])

      product_attribute_option = Gemgento::ProductAttributeOption.find_or_initialize_by_product_attribute_id_and_value(parent.id, value)
      product_attribute_option.label = label
      product_attribute_option.value = value
      product_attribute_option.product_attribute = parent
      product_attribute_option.sync_needed = false
      product_attribute_option.save
    end

    # Push local product attribute set changes to Magento
    def sync_local_to_magento
      if self.sync_needed
        delete_magento
        create_magento

        self.sync_needed = false
        self.save
      end
    end

    # Create a new product attribute set in Magento
    def create_magento
      message = { attribute: self.product_attribute.magento_id, data: {
          label: {
            value: self.label
          }
      }}
      create_response = Gemgento::Magento.create_call(:catalog_product_attribute_add_option, message)
    end

    # Update existing Magento product attribute set
    def delete_magento
      # TODO: update a product attribute set on Magento
    end
  end
end