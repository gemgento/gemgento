module Gemgento
  class CategoriesController < BaseController
    layout 'application'

    def index
      @categories = Gemgento::Category.all
      respond_to do |format|      
        format.js {
          render :json => @categories
        }
      end    

    end


    def show
      respond_to do |format|      
        format.js {
          @category = Gemgento::Category.find(params[:id])
          render :json => @category.products
        }
        format.html {
          @category = Gemgento::Category.find_by(url_key: params[:url_key])
          @product = @category.products
        }
      end    

    end

  end
end