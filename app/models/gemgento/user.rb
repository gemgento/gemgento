module Gemgento
  class User < MagentoObject
    has_many :orders
  end
end