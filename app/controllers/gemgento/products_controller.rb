module Gemgento
  class ProductsController < BaseController

    def show
      if (params[:id])
        @product = Product.find(params[:id])
      else
        @product = Product.active.where(
            gemgento_product_attributes: {code: 'url_key'},
            gemgento_product_attribute_values: {value: params[:url_key]},
        ).first include: :simple_products

        @product.product_attribute_values.reload
      end
    end

    def update
      @product = Gemgento::Product.find_or_initialize_by(magento_id: params[:id])
      data = params[:data]

      @product.magento_id = data[:product_id]
      @product.magento_type = data[:type]
      @product.sku = data[:sku]
      @product.sync_needed = false
      @product.product_attribute_set = Gemgento::ProductAttributeSet.where(magento_id: data[:set]).first
      @product.magento_type = data[:type]
      @product.save

      set_categories(data[:categories], @product) unless data[:categories].nil?
      set_attribute_values_from_magento(data[:additional_attributes], @product) unless data[:additional_attributes].nil?

      render nothing: true
    end

    private

    def set_categories(magento_categories, product)
      product.categories.clear

      # loop through each return category and add it to the product if needed
      magento_categories.each do |magento_category|
        category = Gemgento::Category.where(magento_id: magento_category).first
        product.categories << category unless product.categories.include?(category) # don't duplicate the categories
      end

      product.save
    end

    def set_attribute_values_from_magento(magento_attribute_values, product)
      magento_attribute_values.each do |code, value|

        unless Gemgento::ProductAttribute.where(code: code).empty?

          if code == 'visibility'
            product.visibility = value.to_i
            product.save
          elsif code == 'status'
            product.status = value.to_i == 1 ? 1 : 0
            product.save
          else
            product.set_attribute_value(code, value)
          end

        end

      end
    end

  end
end