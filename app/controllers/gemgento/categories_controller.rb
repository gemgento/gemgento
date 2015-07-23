module Gemgento
  class CategoriesController < ApplicationController

    after_filter :set_last_category, only: :show

    def index
      @current_category = Category.root
      @categories = Category.top_level
    end

    def show
      @current_category = Gemgento::Category.active.find_by!('id = ? OR url_key = ?', params[:id], params[:id])
      @products = current_category.products.active.catalog_visible.page(params[:page]).per(params[:per])
    end

    private

    def set_last_category
      session[:category] = @current_category.id
    end

  end
end