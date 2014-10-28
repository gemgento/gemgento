module Gemgento
  class ProductsController < ApplicationController

    respond_to :json, :html

    def show
      @product = Product.find(params[:id])
    end

  end
end