module Gemgento
  module Magento
    class ProductAttributeSetsController < Gemgento::Magento::BaseController

      def update
        data = params[:data]

        @product_attribute_set = ProductAttributeSet.find_or_initialize_by(magento_id: params[:id])
        @product_attribute_set.magento_id = data[:set_id]
        @product_attribute_set.name = data[:name]
        @product_attribute_set.save

        unless data[:attributes].nil?
          data[:attributes].each do |magento_id|
            attribute = ProductAttribute.find_by(magento_id: magento_id)

            unless attribute.nil?
              @product_attribute_set.product_attributes << attribute unless @product_attribute_set.product_attributes.include?(attribute)
            end
          end
        end

        API::SOAP::Catalog::ProductAttributeMedia.fetch_all_media_types

        render nothing: true
      end

      def destroy
        @product_attribute_set = ProductAttributeSet.find_by(magento_id: params[:id])
        @product_attribute_set.mark_deleted! unless @product_attribute_set.nil?

        render nothing: true
      end

    end
  end
end