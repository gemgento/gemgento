module Gemgento::Api::V1::Base
  extend ActiveSupport::Concern

  included do
    respond_to :json
  end
end