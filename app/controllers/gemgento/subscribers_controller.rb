module Gemgento
  class SubscribersController < BaseController

    def new
      @subscriber = Subscriber.new
    end

    def create
      @subscriber = Gemgento::Subscriber.create(subscriber_params)

      respond_to do |format|
        if @subscriber.save
          format.js { render action: 'create', layout: false }
        else
          format.js { render action: 'errors', layout: false }
        end
      end
    end

    private

    def subscriber_params
      params.require(:subscriber).permit(:name, :email)
    end

  end
end