module Gemgento
  class SearchController < ApplicationController

    def index
      @results = Gemgento::Search.products(params[:query])
    end

  end
end