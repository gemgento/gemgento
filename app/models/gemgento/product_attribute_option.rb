module Gemgento
  class ProductAttributeOption < ActiveRecord::Base
    belongs_to :product_attribute
  end
end