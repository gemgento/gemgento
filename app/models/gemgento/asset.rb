module Gemgento
  class Asset < ActiveRecord::Base
    belongs_to :product
  end
end