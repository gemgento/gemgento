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

    private


    # Push local user changes to magento
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
          API::SOAP::Customer::Customer.create(self)
        else
          API::SOAP::Customer::Customer.update(self)
        end

        self.sync_needed = false
        self.save
      end
    end
  end
end