module Gemgento
  class ProductsController < BaseController
    layout 'application'

  	def index
  	  @products = Product.index
  	end

    def show
      @product = Product.find_by(url_key: params[:permalink])
    end

  end
end