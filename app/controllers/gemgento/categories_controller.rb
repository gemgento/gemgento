module Gemgento
  class CategoriesController < ApplicationController

    def index
      @current_category = Category.root
      @categories = Category.top_level
    end

    def show
      @current_category = Gemgento::Category.active.find_by('id = ? OR url_key = ?', params[:id], params[:url_key])
      @seasonal_categories = Gemgento::Category.where(url_key: %w[accessories denim ready-to-wear victoria-victoria-beckham])
      @products = current_category.products.active.catalog_visible.page(params[:page]).per(params[:per])
    end
  end
end



