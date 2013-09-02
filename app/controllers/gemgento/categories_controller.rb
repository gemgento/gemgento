module Gemgento
  class CategoriesController < BaseController
    layout 'application'

    def index
      @categories = Gemgento::Category.all
      respond_to do |format|
        format.json {
          render :json => @categories.to_json
        }
      end
    end

    def show
      respond_to do |format|
        format.js {
          @category = Gemgento::Category.where(params[:id]).first
          @products = []

          @category.products.configurable.catalog_visible.each do |p|
            @products << {id: p.id, price: p.simple_products.first.price, url_key: p.url_key, name: p.name}
          end
          render :json => @products.to_json
        }

        format.html {
          @category = Gemgento::Category.where(url_key: params[:url_key]).first
          @product = @category.products.configurable.catalog_visible
        }
      end

    end

  end
end