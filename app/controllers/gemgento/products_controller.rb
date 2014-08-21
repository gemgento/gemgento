module Gemgento
  class ProductsController < Gemgento::ApplicationController

    respond_to :json, :html

    def show
      @product = Product.find(params[:id])
    end

  end
end