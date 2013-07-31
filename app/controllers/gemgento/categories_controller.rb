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
          @c = []
          @category.products.configurable.each do |p|
            @c << {id: p.id, price: p.simple_products.first.attribute_value('price'), url_key: p.attribute_value('url_key'), name: p.attribute_value('name')}
          end
          render :json => @c.to_json
        }
        format.html {
          @category = Gemgento::Category.where(url_key: params[:url_key]).first
          @product = @category.products
        }
      end

    end

  end
end