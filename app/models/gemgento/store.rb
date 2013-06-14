module Gemgento
  class Store < ActiveRecord::Base
    has_many :products
    has_many :users

    def self.index
      if Store.find(:all).size == 0
        API::SOAPv2::Miscellaneous::Store.fetch_all
      end

      Store.find(:all)
    end
  end
end