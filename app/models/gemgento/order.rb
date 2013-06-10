module Gemgento
  class Order < MagentoObject
    has_many :products
    belongs_to :user
  end
end