module Gemgento
  class CheckoutController < ApplicationController

    before_action :set_quote
    before_action :validate_item_quantity
    before_action :validate_quote_user

    private

    # Define current quote as instance variable.
    #
    # @return [Gemgento::Quote]
    def set_quote
      @quote = current_quote
    end

    # Cart must have a quantity greater than 0.
    #
    # @return [Boolean]
    def validate_item_quantity

      if @quote.item_quantity <= 0

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
    def validate_quote_user

      # if the user is not signed in and the cart is not a guest checkout, go to login
      if !user_signed_in? && !(@quote.customer_is_guest && !@quote.customer_email.blank?)

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
        shipping_methods = @quote.get_shipping_methods
      else
        shipping_methods = JSON.parse(cookies[:shipping_methods])
      end

      shipping_methods.each do |shipping_method|
        return shipping_method if shipping_method['code'] == @quote.shipping_method
      end

      return nil
    end

    def initialize_shipping_variables
      @shipping_methods = @quote.shipping_methods || []
      cookies[:shipping_methods] = @shipping_methods.to_json
    end

    def initialize_payment_variables
      # @payment_methods = @quote.payment_methods
      @quote.build_payment if @quote.payment.nil?

      unless @quote.customer_is_guest
        @saved_credit_cards = @quote.user.saved_credit_cards
      else
        @saved_credit_cards = []
      end
    end

  end
end
