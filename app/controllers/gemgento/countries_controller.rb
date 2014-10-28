module Gemgento
  class CountriesController < ApplicationController

    respond_to :json, :html

    def index
      @countries = Country.all.includes(:regions)
      respond_with @countries
    end

    def show
      @country = Country.find(params[:id])
      respond_with @country
    end

  end
end
