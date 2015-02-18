module Gemgento
  module ApplicationHelper

    def set_store
      session[:store_id] = Store.current.id if session[:store_id].nil?
    end

    def current_store
      @current_store ||= begin
        if session[:store_id].nil?
          Store.current
        else
          Store.find(session[:store_id])
        end
      end
    end

    def current_quote
      @current_quote ||= Quote.current(current_store, session[:quote], current_user) if @current_quote.nil?
      session[:quote] = @current_quote.id
      return @current_quote
    end

    def create_new_quote
      session.delete :quote
      @current_quote = Quote.current(current_store, nil, current_user)
    end

    def current_category
      @current_category ||= Category.root
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end

    def nav_category_is_active(c)
      return (@curent_category == c or @current_category.children.include?(c)) ? true : false
    end

    def set_layout(html_layout = nil, pjax_layout = false)
      html_layout = Config[:layout] if html_layout.nil?

      if request.url # Check if we are redirected
        response.headers['X-PJAX-URL'] = request.url
      end

      if request.headers['X-PJAX']
        pjax_layout
      elsif request.format == 'json'
        false
      else
        html_layout
      end
    end

    def product_path(product)
      "/products/#{product.url_key}"
    end

    def json_options
      @json_options ||= {
          include_products: params[:include_products] ||= false,
          include_simple_products: params[:include_simple_products] ||= false,
          active: params[:active] ||= true
      }
    end

    def product_asset(product, asset_type_code)
      asset = Gemgento::Asset.find_by_code(product, asset_type_code)

      if asset.nil? && product.magento_type == 'simple' && product.configurable_products.active.any? # check the configurable if the simple doesn't have images.
        asset = Gemgento::Asset.find_by_code(product.configurable_products.active.first, asset_type_code)
      elsif asset.nil?
        asset = product.assets.first.image
      end

      return asset
    end
  end
end
