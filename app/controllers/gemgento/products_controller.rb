module Gemgento
  class ProductsController < BaseController

    def index
      @products = Product.index
    end

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

  end
end