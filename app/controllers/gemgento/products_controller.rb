module Gemgento
  class ProductsController < BaseController
    layout 'application'

    def index
      @products = Product.index
    end

    def show
      if (params[:id])
        @product = Product.where(params[:id]).first
      else
        @product = Product.joins(:product_attribute_values => :product_attribute).where(
            gemgento_product_attributes: {code: 'url_key'},
            gemgento_product_attribute_values: {value: params[:url_key]}).active.first
      end

      respond_to do |format|
        format.js {
          if @product.magento_type == 'configurable'

            @ps = []
            p = @product; first_simple = p.simple_products.active.first
            @ps << {id: p.id, name: p.attribute_value('name'), description: first_simple.attribute_value('description'), price: first_simple.attribute_value('price')}
            @product.simple_products.active.each do |p|
              @ps << {id: p.id, size: p.attribute_value('size'), upc: p.attribute_value('upc'), quantity: '10'}
            end

            render :json => @ps.to_json
          else
            render :json => @product.to_json
          end

        }
        format.html
      end

    end

  end
end