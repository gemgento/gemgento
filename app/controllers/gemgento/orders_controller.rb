module Gemgento
  class OrdersController < BaseController
    layout 'application'

    def cart

    end

    def show
      case current_order.state
        when 'cart'
          render 'cart'
      end
    end

    def create
      @errors = []

      # save the order and mark is as the current cart
      current_order.save
      cookies[:cart] = current_order.id

      add_item

      render nothing: true
    end

    def update
      raise 'Missing action parameter' if params[:activity].nil?

      @errors = []

      case params[:activity]
        when 'add_item'
          @product = add_item
        when 'update_item'
          @product = update_item
        else
          raise "Unknown action - #{params[:activity]}"
      end

      respond_to do |format|
        format.html { render '/checkout/shopping_bag' }
        format.js { render '/gemgento/order/update', :layout => false }
      end
    end

    private
    def add_item
      # validate the parameters
      raise 'Product not specified' if params[:product].nil?
      raise 'Quantity not specified' if params[:quantity].nil?
      raise 'Quantity must be greater than 0' if params[:quantity].to_i <= 0

      product = Gemgento::Product.find(params[:product])
      raise 'Product does not exist' if product.nil?

      # add the item to the order
      current_order.add_item(product, params[:quantity])

      return product
    end

    def update_item
      raise 'Product not specified' if params[:product].nil?
      raise 'Quantity not specified' if params[:quantity].nil?
      raise 'Quantity must be greater than 0' if params[:quantity].to_i <= 0

      product = Gemgento::Product.find(params[:product])
      raise 'Product does not exist' if product.nil?

      # update the item
      current_order.update_item(product, params[:quantity])

      return product
    end

    def set_addresses

    end
  end
end