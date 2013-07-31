module Gemgento
  class UserGroup < ActiveRecord::Base
    def self.index
      if UserGroup.all.size == 0
        API::SOAP::Customer::Customer.fetch_all_user_groups
      end

      UserGroup.all
    end
  end
end