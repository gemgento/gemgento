module Gemgento
  class Address < ActiveRecord::Base
    belongs_to :user
    belongs_to :country
    belongs_to :region
    belongs_to :order

    validates :fname, presence: true, message: 'First name is required'
    validates :lname, presence: true, message: 'Last name is required'
    validates :street, presence: true, message: 'Address is required'
    validates :country, presence: true
    validates :postcode, presence: true, message: 'Postal code is required'
    validates :telephone, presence: true, message: 'Phone number is required'

    attr_accessor :address1, :address2, :address3

    def self.index
      if Address.find(:all).size == 0
        API::SOAP::Customer::Address.fetch_all
      end

      Address.find(:all)
    end

  end
end