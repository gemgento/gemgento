module Gemgento
  class CartController < BaseController
    layout 'application'

    def show
      respond_to do |format|
        format.html { render '/gemgento/cart/show' }
        format.js { render '/gemgento/cart/show', :layout => false }
      end
    end

  end
end