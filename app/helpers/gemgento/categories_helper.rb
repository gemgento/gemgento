module Gemgento::CategoriesHelper

  # Get a list of values for a given attribute.  Values are based on all filters except the filter for the given
  # attribute.
  #
  # @param attribute [Symbol] Gemgento::Attribute code
  # @return [Array(String)]
  def filter_options(attribute)
    filters = @filters.select{ |f| (f[:attribute].is_a?(Array) ? f[:attribute].first[:code] : f[:attribute].code) != attribute.to_s }

    products = Gemgento::Product.active.catalog_visible
                   .joins(:product_categories)
                   .where('gemgento_product_categories.category_id = ?', @current_category.id)
    products = products.filter(filters) if filters.any?

    options = products.map(&attribute)
    options.uniq.reject(&:blank?).sort
  end

  # Cache key values for categories#show fragment cache.
  #
  # @return [Array]
  def cache_key
    cache_key = [@current_category]
    cache_key << user_signed_in? ? current_user.user_group : nil
    cache_key << @products.maximum(:cache_expires_at) if @products
    cache_key += query_params_cache_keys

    return cache_key
  end

  # Cache key values from query string.
  #
  # @return [Array(String)]
  def query_params_cache_keys
    [params[:page]]
  end

end