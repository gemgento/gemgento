module Gemgento::Api::V1::ProductFilters
  extend ActiveSupport::Concern

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