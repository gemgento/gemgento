module Gemgento
  class CartController < Gemgento::ApplicationController
    before_action :set_order
    before_action :create_magento_quote, only: :create
    before_action :validate_order_item, only: [:update, :destroy]

    respond_to :js, :json, :html

    def show
      respond_with @order
    end

    def create
      product = Gemgento::Product.find(params[:order_item][:product_id])

      if !@order.products.include? product # make sure the product isn't in the cart
        @order_item = Gemgento::OrderItem.new(order_item_params)
        @order_item.order = @order
        respond @order_item.save
      else # update the appropriate order_item if it is
        @order_item = @order.order_items.find_by(product: product)
        respond @order_item.update(order_item_params)
      end
    end

    def update
      respond @order_item.update(order_item_params)
    end

    def destroy
      respond @order_item.destroy
    end

    def mini_bag
      render partial: 'shared/mini_bag'
    end

    private

    def set_order
      @order = current_order
    end

    # Create quote in magento if the order doesn't have a magento_quote_id.
    #
    # @return [Boolean]
    def create_magento_quote
      if @order.magento_quote_id.nil?
        if @order.push_cart
          session[:cart] = @order.id
          return true
        else
          respond_to do |format|
            format.html { render 'show' }
            format.json { render json: { result: false, errors: @order.errors.full_messages } }
          end

          return false
        end
      else
        return true
      end
    end

    # Initialize the order_item and verify it belongs to the order.
    #
    # @return [Boolean]
    def validate_order_item
      if @order_item = @order.order_items.find(params[:id])
        return true
      else
        flash.now[:alert] = 'Order item is not in your cart.'
        respond_to do |format|
          format.html { render 'show' }
          format.json { render json: { result: 'false', errors: flash[:alert] }, status: 401 }
        end
        return false
      end
    end

    def order_item_params
      params.require(:order_item).permit(:id, :product_id, :qty_ordered)
    end

    def respond(is_success)
      respond_to do |format|
        if is_success
          format.html { redirect_to cart_path }
          format.json { render json: { result: true } }
        else
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @order_item.errors.full_messages }, status: 422 }
        end
      end
    end

  end
end