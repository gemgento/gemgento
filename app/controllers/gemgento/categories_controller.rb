module Gemgento
  class CategoriesController < Gemgento::ApplicationController

    respond_to :json, :html

    def index
      @current_category = Gemgento::Category.root
      @categories = Gemgento::Category.top_level
      @products = Gemgento::Product.all

      respond_to do |format|
        format.html
        format.json { render json: @categories.as_json({ store: current_store })  }
      end
    end

    def show
      if params[:parent_url_key]
        parent_category = Gemgento::Category.top_level.active.find_by('id = ? OR url_key = ?', params[:parent_id], params[:parent_url_key]) || current_category
        @current_category = parent_category.children.find_by('id = ? OR url_key = ?', params[:id], params[:url_key]) || current_category
      else
        @current_category = Gemgento::Category.active.find_by('id = ? OR url_key = ?', params[:id], params[:url_key]) || current_category
      end

      Gemgento::Product.unscoped do
        @products = @current_category.products.active.catalog_visible.page(params[:page])
      end

      respond_to do |format|
        format.html
        format.json { render json: current_category.as_json({store: current_store, includes_products: true}) }
      end
    end

  end
end
