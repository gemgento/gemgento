module Gemgento
  class CheckoutController < BaseController
    before_filter :auth_order_user

    layout 'application'

    def shopping_bag

    end

    def login

    end

    def address
      if user_signed_in?
        @shipping_address = current_user.get_default_address('shipping')
        @billing_address = current_user.get_default_address('billing')
      else
        @shipping_address = Address.new
        @billing_address = Address.new
      end
    end

    def shipping

    end

    def payment

    end

    def confirm

    end

    private

    def auth_order_user
      unless user_signed_in? || current_order.customer_is_guest
        logger.info 'here'
        redirect_to '/checkout/sign_in'
      end
    end

  end
end