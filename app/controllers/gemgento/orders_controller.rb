module Gemgento
  class OrdersController < BaseController
    layout 'application'

    def cart

    end

    def create
      @errors = []
      add_item_to_order
      render nothing: true
    end

    def update
      @errors = []
      add_item_to_order
      render nothing: true
    end

    private
      def add_item_to_order
        # validate the parameters
        unless params[:product].nil? and params[:quantity].nil?
          raise 'Quantity must be greater than 0'  if params[:quantity].to_i <= 0

          # get the item (product)
          product = Gemgento::Product.find(params[:product])
          raise 'Product does not exist' if product.nil?

          @current_order.save if @current_order.id.nil? # make sure order exists before we add item
          @current_order.add_item(product, params[:quantity])

          cookies[:cart] = @current_order.id
          puts cookies.inspect
        else
          @errors << { add_to_cart: 'Product Id and Quantity are required' }
        end
      end
  end
end