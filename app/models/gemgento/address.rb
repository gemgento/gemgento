module Gemgento
  class Address < ActiveRecord::Base
    belongs_to :user
    belongs_to :country
    belongs_to :region
    belongs_to :order

    validates :fname, presence: {message: 'First name is required'}
    validates :lname, presence: {message: 'Last name is required'}
    validates :street, presence: {message: 'Address is required'}
    validates :region, presence: {message: 'State is required'}
    validates :country, presence: {message: 'Country is required'}
    validates :postcode, presence: {message: 'Postal code is required'}
    validates :telephone, presence: {message: 'Phone number is required'}

    attr_accessor :address1, :address2, :address3

    after_find :explode_street_address
    before_validation :implode_street_address

    def self.index
      if Address.all.size == 0
        API::SOAP::Customer::Address.fetch_all
      end

      Address.all
    end

    def push
      if self.user_address_id.nil?
        API::SOAP::Customer::Address.create(self)
      else
        API::SOAP::Customer::Address.update(self)
      end
    end

    private

    def explode_street_address
      address = self.street.split("\n")
      self.address1 = address[0] unless address[0].nil?
      self.address2 = address[1] unless address[1].nil?
      self.address3 = address[2] unless address[2].nil?
    end

    def implode_street_address
      self.street = self.address1 unless self.address1.nil?
      self.street = "#{self.street}\n#{self.address2}" unless self.address2.nil?
      self.street = "#{self.street}\n#{self.address3}" unless self.address3.nil?
    end

    def sync_local_to_magento
      if self.sync_needed
        if self.user_address_id.nil?
          API::SOAP::Customer::Address.create(self)
        else
          API::SOAP::Customer::Address.update(self)
        end
        self.sync_needed = false
        self.save
      end
    end
  end
end