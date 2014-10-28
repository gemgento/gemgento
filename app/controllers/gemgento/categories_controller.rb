module Gemgento
  class CategoriesController < ApplicationController

    def index
      @current_category = Category.root
      @categories = Category.top_level
    end

    def show
      if params[:parent_url_key]
        parent_category = Category.top_level.active.find_by('id = ? OR url_key = ?', params[:parent_id], params[:parent_url_key]) || current_category
        @current_category = parent_category.children.find_by('id = ? OR url_key = ?', params[:id], params[:url_key]) || current_category
      else
        @current_category = Category.active.find_by('id = ? OR url_key = ?', params[:id], params[:url_key]) || current_category
      end

      @products = @current_category.products.active.catalog_visible.page(params[:page]).per(params[:per])
    end

  end
end
