module Gemgento
  class CategoriesController < BaseController

    respond_to :json, :html

    def index
      @categories = Gemgento::Category.where(include_in_menu: true)

      respond_with @categories
    end

    def show
      @category = Gemgento::Category.find(params[:id])

      respond_with @category
    end

    def update
      @category = Gemgento::Category.find_or_initialize_by(magento_id: params[:id])
      data = params[:data]

      @category.magento_id = data[:category_id]
      @category.is_active = data[:is_active].to_i == 1 ? true : false
      @category.position = data[:position]
      @category.parent = Gemgento::Category.find_by(magento_id: params[:parent_id]) unless params[:parent_id].nil?
      @category.name = data[:name]
      @category.url_key = data[:url_key]
      @category.include_in_menu = data[:include_in_menu]
      @category.sync_needed = false
      @category.save

      render nothing: true
    end

  end
end
