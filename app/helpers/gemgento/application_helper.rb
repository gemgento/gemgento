module Gemgento
  module ApplicationHelper

    def set_store
      if session[:store_id].nil?
        session[:store_id] = Gemgento::Store.current.id
      end
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
      return  (@current_category.id == c.id or @current_category.ancestors.include?(c)) ? true : false
    end
  end
end
