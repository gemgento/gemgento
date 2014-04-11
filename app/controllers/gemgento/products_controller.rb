module Gemgento
  class ProductsController < ApplicationController

    respond_to :json, :html

    def show
      if params[:id]
        if params[:updated_at] # only return the product if it was updated since specified timestamp
          @product = Product.includes(:simple_products).where('updated_at > ? AND id = ?', params[:updated_at], params[:id]).first
        else
          @product = Product.includes(:simple_products).find(params[:id])
        end
      else
        if params[:updated_at] # only return the product if it was updated since specified timestamp
          @product = Product.active.where('updated_at > ?', params[:updated_at]).where(
              gemgento_product_attributes: {code: 'url_key'},
              gemgento_product_attribute_values: {value: params[:url_key]},
          ).first include: :simple_products
        else
          @product = Product.active.where(
              gemgento_product_attributes: {code: 'url_key'},
              gemgento_product_attribute_values: {value: params[:url_key]},
          ).first include: :simple_products
        end

        @product.product_attribute_values.reload unless @product.nil?
      end

      not_found if @product.nil?

      respond_to do |format|
        format.html
        format.json { render json: @product.as_json({ store: current_store }) }
      end
    end

  end
end