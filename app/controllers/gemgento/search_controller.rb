module Gemgento
  class SearchController < BaseController
    layout 'application'

    def index
      @results = Gemgento::Search.products(params[:query])

      respond_to do |format|
        Rails.logger.info format.inspect
        if @results.length == 0
          format.html { render 'gemgento/search/index' }
          format.js { render 'gemgento/search/no_results', :layout => false }
        else
          render 'gemgento/search/index'
        end
      end
    end

  end
end