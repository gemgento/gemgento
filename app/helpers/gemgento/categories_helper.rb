module Gemgento::CategoriesHelper

  # Get a list of values for a given attribute.  Values are based on all filters except the filter for the given
  # attribute.
  #
  # @param attribute [Symbol] Gemgento::Attribute code
  # @return [Array(String)]
  def filter_options(attribute)
    options = []

    @current_category.children.active.each do |cat|
      filters = collection_filters.select{ |f| (f[:attribute].is_a?(Array) ? f[:attribute].first[:code] : f[:attribute].code) != attribute.to_s }
      products = Gemgento::Product.active.catalog_visible
                     .joins(:product_categories)
                     .where('gemgento_product_categories.category_id = ?', cat.id)
      products = products.filter(filters) if filters.any?

      options = options + products.map(&attribute)
    end

    options.uniq.reject(&:blank?).sort
  end

  # URL that includes the attribute, or attributes.  This will remove certain existing attributes if they are not relevant.
  #
  # @param attribute [Symbol] Gemgento::Attribute code
  # @param value [Mixed]
  # @param price_range [PriceRange]
  # @return [String]
  def filter_path(attribute = nil, value = nil, price_range = nil)
    query_params = params.except(*request.path_parameters.keys)
    query_params = query_params.merge(attribute => value) unless attribute.nil? || value.nil?

    unless price_range.nil?
      query_params = query_params.merge(price_min: price_range.min) unless price_range.min.nil?
      query_params = query_params.merge(price_max: price_range.max) unless price_range.max.nil?
    end

    query_params.delete(:opacity) if query_params[:color_filter_primary] && query_params[:color_filter_primary].downcase != 'white'
    query_params.delete(:color_filter_secondary) if query_params[:color_filter_primary] != params[:color_filter_primary]

    "#{request.original_url.split('?').first}?#{query_params.to_query}"
  end

end