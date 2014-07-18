module Gemgento
  class Magento::ProductAttributesController < MagentoController

    def update
      data = params[:data]

      unless Gemgento::ProductAttribute.ignored.include?(data[:attribute_code])
        @product_attribute = Gemgento::ProductAttribute.find_or_initialize_by(magento_id: params[:id])
        @product_attribute.magento_id = data[:attribute_id]
        @product_attribute.code = data[:attribute_code]
        @product_attribute.frontend_input = data[:frontend_input]
        @product_attribute.default_value = data[:default_value]
        @product_attribute.scope = data[:scope]
        @product_attribute.is_unique = data[:is_unique].to_i == 1 ? true : false
        @product_attribute.is_required = data[:is_required].to_i == 1 ? true : false
        @product_attribute.is_configurable = data[:is_configurable].to_i == 1 ? true : false
        @product_attribute.is_searchable = data[:is_searchable].to_i == 1 ? true : false
        @product_attribute.is_visible_in_advanced_search = data[:is_visible_in_advanced_search].to_i == 1 ? true : false
        @product_attribute.is_comparable = data[:is_comparable].to_i == 1 ? true : false
        @product_attribute.is_used_for_promo_rules = data[:is_used_for_promo_rules].to_i == 1 ? true : false
        @product_attribute.used_in_product_listing = data[:used_in_product_listing].to_i == 1 ? true : false
        @product_attribute.save


        set_options(@product_attribute, data[:options]) unless data[:options].nil?

        if @product_attribute.frontend_input == 'media_image'
          Gemgento::API::SOAP::Catalog::ProductAttributeMedia.fetch_all_media_types
        end
      end

      render nothing: true
    end

    def destroy
      @product_attribute = Gemgento::ProductAttribute.find_by(magento_id: params[:id])
      @product_attribute.mark_deleted! unless @product_attribute.nil?

      render nothing: true
    end

    private

    def set_options(product_attribute, options)
      attribute_option_ids = []
      options.each do |store_options|
        next if store_options[:options].nil?

        store = Gemgento::Store.find_by(magento_id: store_options[:store_id])

        if store
          store_options[:options].each_with_index do |option, index|
            product_attribute_option = Gemgento::ProductAttributeOption.find_or_initialize_by(value: option[:value], product_attribute: product_attribute, store: store)
            product_attribute_option.product_attribute = product_attribute
            product_attribute_option.value = option[:value]
            product_attribute_option.label = option[:label]
            product_attribute_option.order = index
            product_attribute_option.store = store
            product_attribute_option.sync_needed = false
            product_attribute_option.save

            attribute_option_ids << product_attribute_option.id
          end
        end
      end

      product_attribute.product_attribute_options.
          where('id NOT IN (?)', attribute_option_ids).
          destroy_all
    end

  end
end