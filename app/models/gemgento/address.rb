module Gemgento
  class Address < ActiveRecord::Base
    belongs_to :user
    belongs_to :country
    belongs_to :region
    belongs_to :order

    validates :fname, length: { minimum: 2 }
    validates :lname, length: { minimum: 2 }
    validates :street, length: { minimum: 2 }
    validates :country, presence: true

    attr_accessor :address1, :address2, :address3

    def self.index
      if Address.find(:all).size == 0
        API::SOAP::Customer::Address.fetch_all
      end

      Address.find(:all)
    end

  end
end