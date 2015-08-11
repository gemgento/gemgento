module Gemgento
  class CategoriesController < ApplicationController

    before_filter :set_filters, only: :show
    after_filter :set_last_category, only: :show

    def index
      @current_category = Category.root
      @categories = Category.top_level
    end

    def show
      @current_category = Gemgento::Category.active.find_by!('id = ? OR url_key = ?', params[:id], params[:id])
      @products = current_category.products.active.catalog_visible
      @products = @products.filter(@filters) unless @filters.empty?
      @products = @products.page(params[:page]).per(params[:per])
    end

    private

    # Get an array of all the active filters.
    #
    # @return [Array(Hash(:attribute, :value, :operand))]
    def set_filters
      @filters ||= begin
        filters = []
        filters << { attribute: Gemgento::ProductAttribute.find_by!(code: 'color'), value: params[:color] } unless params[:color].blank?
        filters
      end
    end

    def set_last_category
      session[:category] = @current_category.id
    end

  end
end