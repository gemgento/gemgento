module Gemgento
  class SearchController < ApplicationController

    respond_to :json, :html

    def index
      @results = Search.products(params[:query])

      respond_to do |format|
        format.html
        format.json {render json: @results}
      end
    end

  end
end
