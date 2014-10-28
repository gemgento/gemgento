module Gemgento
  class RegionsController < ApplicationController

  respond_to :json, :html

    def index
      @regions = Region.all

      respond_with @regions
    end

    def show
      @region = Region.find(params[:id])

      respond_with @region
    end
  end
end
