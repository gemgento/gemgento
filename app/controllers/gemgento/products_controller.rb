module Gemgento
  class ProductsController < BaseController
    layout 'application'

  	def index
  	  @products = Product.index
  	end

    def show
      @product = Gemgento::Product.joins(:product_attribute_values => :product_attribute).where(
          gemgento_product_attributes: { code: 'url_key' },
          gemgento_product_attribute_values: { value: params[:url_key] }
      ).first
    end

  end
end