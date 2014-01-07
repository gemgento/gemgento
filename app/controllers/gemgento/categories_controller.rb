module Gemgento
  class CategoriesController < BaseController

    respond_to :json, :html

    def index
      respond_with @categories = Gemgento::Category.all
    end

    def show
      respond_with(
        @category = Gemgento::Category.find(params[:id]),
        @products = @category.products.active.catalog_visible.order('gemgento_product_categories.position ASC')
      )
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
      @category.sync_needed = false
      @category.save

      render nothing: true
    end

  end
end
