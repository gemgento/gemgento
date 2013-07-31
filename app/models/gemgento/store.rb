module Gemgento
  class Store < ActiveRecord::Base
    has_many :products
    has_many :users

    def self.index
      if Store.all.size == 0
        API::SOAP::Miscellaneous::Store.fetch_all
      end

      Store.all
    end
  end
end