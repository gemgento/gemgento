module Gemgento
  class CountriesController < BaseController

    respond_to :json, :html

    def index
      @countries = Gemgento::Country.all

      respond_with @countries
    end

    def show
      @country = Gemgento::Country.find(params[:id])

      respond_with @country
    end
  end
end
