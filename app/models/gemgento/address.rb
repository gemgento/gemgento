module Gemgento
  class Address < ActiveRecord::Base
    belongs_to :user
    belongs_to :country
    belongs_to :region
    belongs_to :order

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :street, presence: true
    validates :region, presence: true
    validates :country, presence: true
    validates :postcode, presence: true
    validates :telephone, presence: true

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

    def as_json(options = nil)
      result = super
      result['address1'] = self.address1
      result['address2'] = self.address2
      result['address3'] = self.address3

      return result
    end

    private

    def explode_street_address
      address = self.street.split("\n")
      self.address1 = address[0] unless address[0].nil?
      self.address2 = address[1] unless address[1].nil?
      self.address3 = address[2] unless address[2].nil?
    end

    def implode_street_address
      self.street = [self.address1, self.address2, self.address3].join("\n")
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