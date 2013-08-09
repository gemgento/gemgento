module Gemgento
  class SubscribersController < ApplicationController

    def create
      @subscriber = Subscriber.new
      @subscriber.name = params[:subscriber][:name]
      @subscriber.email = params[:subscriber][:email]
      respond_to do |format|      
        format.js { 
          render :action => (@subscriber.save) ? 'create' : 'errors', :layout => false 
        }
      end    
    end

  end
end