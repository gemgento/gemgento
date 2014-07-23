module Gemgento
  class CountriesController < Gemgento::ApplicationController

    def index
      @countries = Gemgento::Country.all.includes(:regions)
      respond_with @countries
    end

    def show
      @country = Gemgento::Country.find(params[:id])
      respond_with @country
    end

  end
end
