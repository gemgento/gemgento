module Gemgento
  class Api::V1::SearchController < ApplicationController
    include Gemgento::Api::V1::Base
    include Gemgento::Api::V1::ProductFilters

    def index
      @products = Gemgento::Search.products(params[:query])
      @products = @products.where(basic_filters)
      @products = @products.filter(attribute_filters, current_store) if attribute_filters.any?
      @products = @products.page(@page[:number]).per(@page[:size])
    end

  end
end