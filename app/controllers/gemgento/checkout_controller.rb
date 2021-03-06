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

      if @quote.new_record?
        respond_to do |format|
          format.html { redirect_to cart_path, alert: 'Shopping cart is no longer valid.  Please create a new order.' }
          format.json { render json: { result: false, errors: 'Shopping cart is no longer valid.  Please create a new order.' }, status: 422 }
        end
      end
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

    def build_billing_address
      billing_address = current_user.default_billing_address if user_signed_in?
      billing_address = billing_address.nil? ? Address.new : billing_address.duplicate
      billing_address.is_billing = true
      billing_address.is_shipping = false
      billing_address.country = Gemgento::Country.find_by(iso2_code: 'us') unless billing_address.country.present?
      @quote.build_billing_address(billing_address.attributes.reject{ |key| key == 'id' })
    end

    def build_shipping_address
      shipping_address = current_user.default_shipping_address if user_signed_in?
      shipping_address = shipping_address.nil? ? Address.new : shipping_address.duplicate
      shipping_address.is_shipping = true
      shipping_address.is_billing = false
      shipping_address.country = Gemgento::Country.find_by(iso2_code: 'us') unless shipping_address.country.present?
      @quote.build_shipping_address(shipping_address.attributes.reject{ |key| key == 'id' })
    end

    def get_magento_shipping_method
      if cookies[:shipping_methods].nil?
        shipping_methods = @quote.shipping_methods
      else
        shipping_methods = JSON.parse(cookies[:shipping_methods], symbolize_names: true)
      end

      shipping_methods.each do |shipping_method|
        return shipping_method if shipping_method[:code] == @quote.shipping_method
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
        API::SOAP::Authnetcim::Payment.fetch(@quote.user) if Config[:extensions]['authorize-net-cim-payment-module']
        @saved_credit_cards = @quote.user.saved_credit_cards
      else
        @saved_credit_cards = []
      end
    end

    def payment_after_redirect_url
      case @quote.payment.method
        when 'paypal_express'
          "#{Gemgento::Config[:magento][:url]}/paypal/express/start?quote_id=#{@quote.magento_id}&store_id=#{@quote.store.magento_id}#{("&customer_id=#{@quote.user.magento_id}" if @quote.user)}"
        else
          checkout_confirm_path
      end
    end

  end
end
