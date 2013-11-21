module Gemgento
  class ProductAttributesController < BaseController

    def update
      @product_attribute = Gemgento::ProductAttribute.find_or_initialize_by(magento_id: params[:id])
      data = params[:data]

      @product_attribute.magento_id = data[:attribute_id]
      @product_attribute.code = data[:atribute_code]
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
      @product_attribute.is_visible_on_front = data[:is_visible_on_front].to_i == 1 ? true : false
      @product_attribute.used_in_product_listing = data[:used_in_product_listing].to_i == 1 ? true : false

      render nothing: true
    end

  end
end