module Gemgento
  class Api::V1::CategoriesController < ApplicationController
    include ::Gemgento::Api::V1::Base

    def index
      @categories = Category.all.page(params[:page][:number]).per(params[:page][:size])
    end

    def show
      @category = Category.find(params[:id])
    end
  end
end
