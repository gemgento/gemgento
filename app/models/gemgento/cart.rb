module Gemgento
  class Cart < MagentoObject
    has_and_belongs_to_many :products
  end
end