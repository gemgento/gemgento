module Gemgento
  class CartController < BaseController
    layout 'application'

    def show
      respond_to do |format|
        format.html do
          if request.headers['X-PJAX']
            render :layout => false
          end
        end
        format.js { render '/gemgento/cart/show', :layout => false }
      end
    end

  end
end