module Gemgento
  class Api::V1::ProductsController < ApplicationController
    include Gemgento::Api::V1::Base

    def index
      if params[:category_id]
        @products = Gemgento::Category.find(params[:category_id]).products(current_store)
      else
        @products = current_store.products.order(:id)
      end

      @products = @products.where(basic_filters)
      @products = @products.filter(attribute_filters, current_store) if attribute_filters.any?
      @products = @products.page(@page[:number]).per(@page[:size])
    end

    def show
      @product = Gemgento::Product.find(params[:id])
    end

    protected

    def basic_filters
      default_filters.merge(filter_params)
    end

    def default_filters
      {
          status: 1, # enabled
          visibility: [2, 4], # catalog visible
      }
    end

    def attribute_filters
      attribute_filters = []
      all_attribute_codes = Gemgento::ProductAttribute.pluck(:code).uniq.map(&:to_sym)
      filterable_attribute_codes = all_attribute_codes - default_filters.keys
      attribute_filter_params = params.permit(filterable_attribute_codes)

      attribute_filter_params.each do |code, value|
        attribute = Gemgento::ProductAttribute.find_by!(code: code)
        attribute_filters << { attribute: attribute, value: value }
      end

      return attribute_filters
    end

    def filter_params
      params.permit(:status, :visibility, :magento_type, :sku)
    end

  end
end
