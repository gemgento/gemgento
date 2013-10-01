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
      @category = Gemgento::Category.where(params[:id]).first
      @products = @category.products.catalog_visibile.active.order('gemgento_product_categories.position ASC')
    end

  end
end