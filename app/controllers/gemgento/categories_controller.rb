module Gemgento
  class CategoriesController < BaseController

    def index
      @categories = Gemgento::Category.all
    end

    def show
      @category = Gemgento::Category.where(params[:id]).first
      @products = @category.products.catalog_visibile.active.order('gemgento_product_categories.position ASC')
    end

  end
end