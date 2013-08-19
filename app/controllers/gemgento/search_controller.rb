module Gemgento
  class SearchController < BaseController
    layout 'application'

    def index
      @results = Gemgento::Search.products(params[:query])
    end

  end
end