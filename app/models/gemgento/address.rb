module Gemgento
  class Address < ActiveRecord::Base
    belongs_to :users
    belongs_to :country
    belongs_to :region
    belongs_to :order

    def self.index
      if Address.find(:all).size == 0
        API::SOAP::Customer::Address.fetch_all
      end

      Address.find(:all)
    end

  end
end