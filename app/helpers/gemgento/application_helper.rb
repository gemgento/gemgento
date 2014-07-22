module Gemgento
  module ApplicationHelper

    def set_store
      session[:store_id] = Gemgento::Store.current.id if session[:store_id].nil?
    end

    def current_store
      @current_store ||= begin
        if session[:store_id].nil?
          Gemgento::Store.current
        else
          Gemgento::Store.find(session[:store_id])
        end
      end
    end

    def current_order
      @current_order ||= begin
        if cookies[:cart].blank?
          cookies.delete :cart
          Gemgento::Order.get_cart(cookies[:cart], current_store, current_user) if @current_order.nil?
        else
          Gemgento::Order.find(cookies[:cart])
        end
      end

      if @current_order.state != 'cart'
        cookies.delete :cart
        @current_order = Gemgento::Order.get_cart(nil, current_store, current_user)
      end

      unless @current_order.id.nil?
        cookies[:cart] = @current_order.id
      end

      return @current_order
    end

    def create_new_cart
      cookies.delete :cart
      @current_order = Gemgento::Order.get_cart(nil, current_store)
    end

    def current_category
      @current_category ||= Gemgento::Category.root
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end

    def nav_category_is_active(c)
      return (@curent_category == c or @current_category.children.include?(c)) ? true : false
    end

    def set_layout(html_layout = nil, pjax_layout = false)
      html_layout = Gemgento::Config[:layout] if html_layout.nil?

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

  end
end
