module Gemgento
  class CartController < BaseController

    respond_to :js, :json, :html

    def show
      @cart = current_order

      respond_with @cart
    end

    def update
      raise 'Missing action parameter' if params[:activity].nil?

      @errors = []

      case params[:activity]
        when 'add_item'
          @product = add_item

          respond_to do |format|
            format.html { render 'gemgento/checkout/shopping_bag' }

            unless @product
              format.js { render '/gemgento/order/no_inventory', layout: false }
              format.json { render json: { result: false, order: current_order } }
            else
              format.js { render '/gemgento/order/add_item', layout: false }
              format.json { render json: { result: true, order: current_order } }
            end
          end
        when 'update_item'
          @product = update_item

          respond_to do |format|
            format.html { render 'gemgento/checkout/shopping_bag' }

            unless @product
              format.js { render '/gemgento/order/no_inventory', :layout => false }
              format.json { render json: { result: false, order: current_order } }
            else
              format.js { render '/gemgento/order/update_item', :layout => false }
              format.json { render json: { result: true, order: current_order } }
            end
          end
        when 'remove_item'
          remove_item

          respond_to do |format|
            format.html { render 'gemgento/checkout/shopping_bag' }
            format.js { render '/gemgento/order/remove_item', :layout => false }
            format.json { render json: { result: true, order: current_order } }
          end
        else
          raise "Unknown action - #{params[:activity]}"
          render nothing: true
      end
    end

    private

    def add_item
      # validate the parameters
      raise 'Product ID not specified' if params[:product_id].nil?
      raise 'Quantity not specified' if params[:quantity].nil?
      raise 'Quantity must be greater than 0' if params[:quantity].to_i <= 0

      product = Gemgento::Product.find(params[:product_id])
      raise 'Product does not exist' if product.nil?

      if product.in_stock? params[:quantity]
        # add the item to the order
        current_order.add_item(product, params[:quantity])
        return product
      else
        return false
      end
    end

    def update_item
      raise 'Product not specified' if params[:product_id].nil?
      raise 'Quantity not specified' if params[:quantity].nil?
      raise 'Quantity must be greater than 0' if params[:quantity].to_i <= 0

      product = Gemgento::Product.find(params[:product_id])
      raise 'Product does not exist' if product.nil?

      if product.in_stock? params[:quantity]
        # update the item
        current_order.update_item(product, params[:quantity])
        return product
      else
        return false
      end
    end

    def remove_item
      raise 'Product not specified' if params[:product_id].nil?

      product = Gemgento::Product.find(params[:product_id])
      raise 'Product does not exist' if product.nil?

      current_order.remove_item(product)
    end

  end
end