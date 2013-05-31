module Gemgento
  class CategoriesController < BaseController
    layout 'application'

    def show
      @category = Gemgento::Category.find_by(url_key: params[:url_key])
      @product = @category.products
    end

  end
end