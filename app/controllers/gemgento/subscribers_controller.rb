module Gemgento
  class SubscribersController < ApplicationController

    def create
      @subscriber = Gemgento::Subscriber.create(subscriber_params)

      respond_to do |format|
        format.js {
          render :action => (@subscriber.save) ? 'create' : 'errors', :layout => false
        }
      end
    end

    private

    def subscriber_params
      params.require(:subscriber).permit(:name, :email)
    end

  end
end