module Gemgento
  class CartController < Gemgento::ApplicationController
    ssl_allowed

    respond_to :js, :json, :html

    before_action :set_totals, only: :show, if: :is_cart?

    def show
      @cart = current_order

      respond_with @cart
    end

    def create
      @errors = []

      # save the order and mark is as the current cart
      current_order.save
      cookies[:cart] = current_order.id

      add_item

      respond_to do |format|
        format.html { render 'gemgento/checkout/shopping_bag' }
        format.js { render '/gemgento/order/add_item', :layout => false }
      end
    end

    def update
      raise 'Missing action parameter' if params[:activity].nil?
      @errors = []

      if current_order.id.nil?
        current_order.user = current_user
        current_order.save
        cookies[:cart] = current_order.id
      end

      case params[:activity]
        when 'add_item'
          @product = add_item
          current_order.reload

          respond_to do |format|
            unless @product
              format.html {
                begin
                  redirect_to :back
                rescue
                  redirect_to root_path
                end
              }
              format.js { render '/gemgento/order/no_inventory', layout: false }
              format.json {
                render json: {
                    result: false,
                    errors: flash[:error],
                    order: current_order
                }
                flash[:error] = false
              }
            else
              format.html { redirect_to action: 'show' }
              format.js { render '/gemgento/order/add_item', layout: false }
              format.json { render json: { result: true, order: current_order } }
            end
          end
        when 'update_item'
          @product = update_item
          current_order.reload

          respond_to do |format|
            unless @product
              format.html {
                begin
                  redirect_to :back
                rescue
                  redirect_to root_path
                end
              }
              format.js { render '/gemgento/order/no_inventory', layout: false }
              format.json {
                render json: {
                  result: false,
                  errors: flash[:error],
                  order: current_order
                }
                flash[:error] = false
              }
            else
              format.html { redirect_to action: 'show' }
              format.js { render '/gemgento/order/update_item', layout: false }
              format.json { render json: {result: true, order: current_order} }
            end
          end
        when 'remove_item'
          remove_item
          current_order.reload

          respond_to do |format|
            format.html { redirect_to action: 'show' }
            format.js { render '/gemgento/order/remove_item', layout: false }
            format.json { render json: {result: true, order: current_order} }
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

      order_item = current_order.order_items.find_by(product: product)

      if order_item.nil?
        if product.in_stock? params[:quantity], current_store
          # add the item to the order
          result = current_order.add_item(product, params[:quantity], params[:options])
          if result == true
            return product
          else
            flash[:error] = result
            return false
          end
        else
          return false
        end
      else
        params[:quantity] = params[:quantity].to_f + order_item.qty_ordered
        return update_item
      end
    end

    def update_item
      raise 'Product not specified' if params[:product_id].nil?
      raise 'Quantity not specified' if params[:quantity].nil?
      raise 'Quantity must be greater than 0' if params[:quantity].to_i <= 0

      product = Gemgento::Product.find(params[:product_id])
      raise 'Product does not exist' if product.nil?

      if product.in_stock? params[:quantity], current_store
        # update the item
        result = current_order.update_item(product, params[:quantity], params[:options])
        if result == true
          return product
        else
          flash[:error] = result
          return false
        end
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

    def set_totals
      totals = current_order.get_totals
      @totals = {
          subtotal: 0,
          discounts: {},
          gift_card: 0,
          nominal: {},
          shipping: 0,
          tax: 0,
          total: 0
      }

      unless totals.nil?
        totals.each do |total|
          unless total[:title].include? 'Discount'
            if !total[:title].include? 'Nominal' # regular checkout values
              if total[:title].include? 'Subtotal'
                @totals[:subtotal] = total[:amount].to_f
                @totals[:subtotal] = current_order.subtotal if @totals[:subtotal] == 0
              elsif total[:title].include? 'Grand Total'
                @totals[:total] = total[:amount].to_f
              elsif total[:title].include? 'Tax'
                @totals[:tax] = total[:amount].to_f
              elsif total[:title].include? 'Shipping'
                @totals[:shipping] = total[:amount].to_f
              elsif total[:title].include? 'Gift'
                @totals[:gift_card] = total[:amount].to_f
              end
            else # checkout values for a nominal item
              if total[:title].include? 'Subtotal'
                @totals[:nominal][:subtotal] = total[:amount].to_f
                @totals[:nominal][:subtotal] = current_order.subtotal if @totals[:nominal][:subtotal] == 0
              elsif total[:title].include? 'Total'
                @totals[:nominal][:total] = total[:amount].to_f
              elsif total[:title].include? 'Tax'
                @totals[:nominal][:tax] = total[:amount].to_f
              elsif total[:title].include? 'Shipping'
                @totals[:nominal][:shipping] = total[:amount].to_f
              elsif total[:title].include? 'Gift'
                @totals[:gift_card] == total[:amount].to_f
              end
            end
          else
            code = total[:title][10..-2]
            @totals[:discounts][code.to_sym] = total[:amount]
          end
        end

        # nominal shipping isn't calculated correctly, so we can set it based on known selected values
        if !@totals[:nominal].has_key?(:shipping) && @totals[:nominal].has_key?(:subtotal) && current_order.shipping_address
          if @totals[:shipping] && @totals[:shipping] > 0
            @totals[:nominal][:shipping] = @totals[:shipping]
          elsif shipping_method = get_magento_shipping_method
            @totals[:nominal][:shipping] = shipping_method['price'].to_f
          else
            @totals[:nominal][:shipping] = 0.0
          end

          @totals[:nominal][:total] += @totals[:nominal][:shipping] if @totals[:nominal].has_key?(:total) # make sure the grand total reflects the shipping changes
        end
      end
    end

    def is_cart?
      !current_order.magento_quote_id.nil?
    end

  end
end