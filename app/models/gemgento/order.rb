module Gemgento
  class Order < ActiveRecord::Base
    has_many :products
    belongs_to :user
  end
end