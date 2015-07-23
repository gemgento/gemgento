module Gemgento
  class ProductsController < ApplicationController

    respond_to :json, :html

    def show
      @product = Gemgento::Product.find(params[:id])
      @current_category = @product.current_category(session[:category])
    end

  end
end