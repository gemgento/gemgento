module Gemgento
  class Address < ActiveRecord::Base
    belongs_to :user
    belongs_to :country
    belongs_to :region
    belongs_to :order

    validates :first_name, :last_name, :street, :country, :postcode, :telephone, presence: true
    validates :region, presence: true, if: ->{ !self.country.nil? && !self.country.regions.empty? }

    validates_uniqueness_of :user, scope: [:street, :city, :country, :region, :postcode, :telephone, :order],
                            message: 'address is not unique',
                            if: ->{ self.order.nil? && !self.user.nil? }

    attr_accessor :address1, :address2, :address3

    after_find :explode_street_address
    before_validation :implode_street_address

    after_save :sync_local_to_magento

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
      result['country'] = self.country.name unless self.country.nil?
      result['region'] = self.region.code unless self.region.nil?
      return result
    end

    def unique_entry

    end

    private

    def explode_street_address
      address = self.street.split("\n")
      self.address1 = address[0] unless address[0].blank?
      self.address2 = address[1] unless address[1].blank?
      self.address3 = address[2] unless address[2].blank?
    end

    def implode_street_address
      street = []
      street << self.address1 unless self.address1.blank?
      street << self.address2 unless self.address2.blank?
      street << self.address3 unless self.address3.blank?
      self.street = street.join("\n") unless street.blank?
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