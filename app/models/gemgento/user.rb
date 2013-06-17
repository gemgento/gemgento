module Gemgento
  class User < ActiveRecord::Base
    belongs_to :user_group
    belongs_to :store
    after_save :sync_local_to_magento

    def self.index
      if User.find(:all).size == 0
        API::SOAP::Customer::Customer.fetch_all
      end

      User.find(:all)
    end
  end
end