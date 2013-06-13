module Gemgento
  class GiftMessage < ActiveRecord::Base
    belongs_to :order_item
    belongs_to :order

    def self.sync_magento_to_local(source)
      puts source
      exit
    end
  end
end