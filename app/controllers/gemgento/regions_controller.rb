module Gemgento
  class RegionsController < Gemgento::ApplicationController

  respond_to :json, :html

    def index
      @regions = Gemgento::Region.all

      respond_with @regions
    end

    def show
      @region = Gemgento::Region.find(params[:id])

      respond_with @region
    end
  end
end
