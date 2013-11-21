module Gemgento
  class ProductAttributeSetsController < BaseController

    def update
      @product_attribute_set = Gemgento::ProductAttributeSet.find_or_initialize_by(magento_id: params[:id])
      data = params[:data]

      @product_attribute_set.magento_id = params[:set_id]
      @product_attribute_set.name = params[:name]
      @product_attribute_set.save

      render nothing: true
    end

  end
end