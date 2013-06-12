module Gemgento
  class OrderAddress < ActiveRecord::Base
    belongs_to :order
    belongs_to :region
    belongs_to :country
    belongs_to :address
  end
end