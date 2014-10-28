module Gemgento
  class CheckoutController < ApplicationController

    before_action :set_order
    before_action :validate_line_item_count
    before_action :validate_order_user

    private

    # Define current_quote as instance variable.
    #
    # @return [Void]
    def set_order
      @order = current_quote
    end

    # Cart must have a quantity greater than 0.
    #
    # @return [Boolean]
    def validate_line_item_count
      if current_quote.item_count <= 0
        respond_to do |format|
          format.html { redirect_to cart_path, alert: 'You do not have any products in your cart.' }
          format.json { render json: { result: false, errors: 'You do not have any products in your cart.' }, status: 422 }
        end

        return false
      else
        return true
      end
    end

    # Cart must be associated with a user or marked as guest checkout.
    #
    # @return [Boolean]
    def validate_order_user
      # if the user is not signed in and the cart is not a guest checkout, go to login
      if !user_signed_in? && !(current_quote.customer_is_guest && !current_quote.customer_email.blank?)
        respond_to do |format|
          format.html { redirect_to checkout_login_path, alert: 'You must login or select guest checkout before continuing.' }
          format.json { render json: { result: false, errors: 'You must login or select guest checkout before continuing.' }, status: 422 }
        end

        return false
      else
        return true
      end
    end

    def get_magento_shipping_method
      if cookies[:shipping_methods].nil?
        shipping_methods = current_quote.get_shipping_methods
      else
        shipping_methods = JSON.parse(cookies[:shipping_methods])
      end

      shipping_methods.each do |shipping_method|
        if shipping_method['code'] == current_quote.shipping_method
          return shipping_method
        end
      end

      return nil
    end

    def payment_params
      params.require(:order).require(:payment).permit(:method, :cc_cid, :cc_number, :cc_type, :cc_exp_year, :cc_exp_month, :cc_owner, :save_card, :payment_id)
    end

    def initialize_shipping_variables
      @shipping_methods = current_quote.get_shipping_methods
      cookies[:shipping_methods] = @shipping_methods.to_json
    end

    def initialize_payment_variables
      unless @payment
        current_quote.build_payment if current_quote.payment.nil?
        @payment = current_quote.payment
      end

      @payment_methods = current_quote.get_payment_methods

      unless current_quote.customer_is_guest
        @saved_credit_cards = current_user.saved_credit_cards
      else
        @saved_credit_cards = []
      end
    end

  end
end
