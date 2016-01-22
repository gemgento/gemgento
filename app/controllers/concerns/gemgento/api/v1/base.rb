module Gemgento::Api::V1::Base
  extend ActiveSupport::Concern

  included do
    respond_to :json

    before_action :set_page, only: :index
  end

  def set_page
    @page = {}
    @page[:number] = (params[:page] && params[:page][:number]) ? params[:page][:number] : 1
    @page[:size] = (params[:page] && params[:page][:size]) ? params[:page][:size] : 20
  end
end