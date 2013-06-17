module Gemgento
  class UserGroup < ActiveRecord::Base
    def self.index
      if UserGroup.find(:all).size == 0
        API::SOAP::Customer::Customer.fetch_all_user_groups
      end

      UserGroup.find(:all)
    end
  end
end