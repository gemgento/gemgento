module Gemgento
  class ProductsController < Gemgento::ApplicationController

    respond_to :json, :html

    def show
      if params[:id]
        @product = Product.find(params[:id])
      else
        @product = Product.active.where(
            gemgento_product_attributes: {code: 'url_key'},
            gemgento_product_attribute_values: {value: params[:url_key]},
        ).first

        @product.product_attribute_values.reload unless @product.nil?
      end

      not_found if @product.nil?
    end

  end
end