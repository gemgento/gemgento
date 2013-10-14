module Gemgento
  class SearchController < BaseController

    def index
      @results = Gemgento::Search.products(params[:query])

      if request.xhr?
        render layout: false
      end
    end

  end
end