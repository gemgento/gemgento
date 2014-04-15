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
      @current_order = Gemgento::Order.get_cart(cookies[:cart], current_store, current_user) if @current_order.nil?

      if @current_order.state != 'cart'
        cookies[:cart] = nil
        @current_order = Gemgento::Order.get_cart(nil, current_store, current_user)

        unless @current_order.id.nil?
          cookies[:cart] = @current_order.id
        end
      end

      @current_order
    end

    def create_new_cart
      @current_order = Gemgento::Order.get_cart(nil, current_store)
    end

    def current_category
      @current_category ||= Gemgento::Category.root
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end

  end
end
