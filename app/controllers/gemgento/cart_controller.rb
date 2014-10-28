module Gemgento
  class CartController < ApplicationController
    before_action :set_quote
    before_action :create_magento_quote, only: :create, if: '@quote.new_record?'
    before_action :validate_line_item, only: [:update, :destroy]

    respond_to :js, :json, :html

    def show
      respond_with @quote
    end

    def create
      product = Product.find(params[:line_item][:product_id])

      if !@quote.products.include? product # make sure the product isn't in the cart
        @line_item = LineItem.new(line_item_params)
        @line_item.itemizable = @quote
        respond @line_item.save
      else # update the appropriate line_item if it is
        @line_item = @quote.line_items.find_by(product: product)
        params[:line_item][:qty_ordered] = params[:line_item][:qty_ordered].to_d + @line_item.qty_ordered # increase existing qty by requested qty
        respond @line_item.update(line_item_params)
      end
    end

    def update
      respond @line_item.update(line_item_params)
    end

    def destroy
      respond @line_item.destroy
    end

    def mini_bag
      render partial: 'shared/mini_bag'
    end

    private

    def set_quote
      @quote = current_quote
    end

    # If this is a new quote, save the record first.
    #
    # @return [Boolean]
    def create_magento_quote
      if @quote.save
        session[:quote] = @quote.id
        return true
      else
        respond_to do |format|
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @quote.errors.full_messages } }
        end

        return false
      end
    end

    # Initialize the line_item and verify it belongs to the quote.
    #
    # @return [Boolean]
    def validate_line_item
      if @line_item = @quote.line_items.find(params[:id])
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

    def line_item_params
      params.require(:line_item).permit(:id, :product_id, :qty_ordered)
    end

    def respond(is_success)
      respond_to do |format|
        if is_success
          format.html { redirect_to cart_path }
          format.json { render json: { result: true } }
        else
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @line_item.errors.full_messages }, status: 422 }
        end
      end
    end

  end
end