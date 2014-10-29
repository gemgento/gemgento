module Gemgento

  # @author Gemgento LLC
  class Address < ActiveRecord::Base
    belongs_to :user
    belongs_to :country
    belongs_to :region

    has_one :shopify_adapter, class_name: 'Adapter::ShopifyAdapter', as: :gemgento_model

    validates :region, presence: true, if: -> { !self.country.nil? && self.country.regions.any? }

    validates_uniqueness_of :user,
                            scope: [:street, :city, :country, :region, :postcode, :telephone],
                            message: 'address is not unique',
                            unless: -> { self.user.nil? }

    attr_accessor :address1, :address2, :address3

    after_find :explode_street_address
    before_validation :strip_whitespace, :implode_street_address

    after_save :sync_local_to_magento
    after_save :enforce_single_default, unless: ->{ self.user.nil? }

    before_destroy :destroy_magento

    default_scope -> { order(is_default_billing: :desc, is_default_shipping: :desc, updated_at: :desc) }

    # Pushes Address changes to Magento if the address belongs to a User.  Creates a new address if one does not exist
    # and updates existing addresses.
    #
    # @return [Boolean] if the push to Magneto was successful
    def push
      if self.user_address_id.nil?
        API::SOAP::Customer::Address.create(self)
      else
        API::SOAP::Customer::Address.update(self)
      end
    end

    # Return the Address as JSON.
    #
    # @param options [Hash] an optional hash of options.
    # @return [String]
    def as_json(options = nil)
      result = super
      result['address1'] = self.address1
      result['address2'] = self.address2
      result['address3'] = self.address3
      result['country'] = self.country.name unless self.country.nil?
      result['region'] = self.region.code unless self.region.nil?
      return result
    end

    # Save order addresses to user address book.  Any new address will be default.
    #
    # @param order [Order] the order to save addresses from
    # @param save_billing [Boolean] true to save the billing address
    # @param save_shipping [Boolean] true to save the shipping address
    # @param shipping_same_as_billing [Boolean] true if the shipping and billing addresses are the same
    def self.save_from_order(order, save_billing, save_shipping, shipping_same_as_billing)
      if save_billing && shipping_same_as_billing
        Address.copy_to_address_book(order.billing_address, order.user, true, true)
      elsif save_billing && !shipping_same_as_billing
        Address.copy_to_address_book(order.billing_address, order.user, true, false)
      end

      if save_shipping && !shipping_same_as_billing
        Address.copy_to_address_book(order.shipping_address, order.user, false, true)
      end
    end

    # Copy an existing address to a user's address book.
    #
    # @param source [Address] the existing address that will be copied.
    # @param user [User] the user who will be associated with the new address.
    # @param is_default [Boolean] true if the new address will be the default for it's type, false otherwise.
    # @return [Address] the newly created Address.
    def self.copy_to_address_book(source, user, is_default_billing = false, is_default_shipping = false)
      address = source.dup
      address.user = user
      address.is_default_billing = is_default_billing
      address.is_default_shipping = is_default_shipping
      address.sync_needed = true
      address.save

      return address
    end

    # Set the street attribute.  Override required to explode the street into address lines.
    def street=(value)
      super
      explode_street_address
    end

    # Duplicate an address.  Different from dup because it avoids unique magento attributes and includes
    # country and region associations.
    #
    # @return [Address] newly duplicated address
    def duplicate
      address = self.dup
      address.region = self.region
      address.country = self.country
      address.user = nil
      address.is_default_billing = false
      address.is_default_shipping = false
      address.increment_id = nil
      address.sync_needed = false
      address.user_address_id = nil

      return address
    end

    private

    # Strip attributes where leading/trailing whitespace could pose problems.
    #
    # @return [void]
    def strip_whitespace
      self.first_name = self.first_name.strip unless self.first_name.nil?
      self.last_name = self.last_name.strip unless self.last_name.nil?
      self.city = self.city.strip unless self.city.nil?
      self.postcode = self.postcode.strip unless self.postcode.nil?
    end

    # Split the street attribute into 3 address line attributes. Magento stores street addresses lines as a
    # single attribute that uses line breaks to differentiate the lines.
    #
    # @return [void]
    def explode_street_address
      address = self.street.split("\n")
      self.address1 = address[0] unless address[0].blank?
      self.address2 = address[1] unless address[1].blank?
      self.address3 = address[2] unless address[2].blank?
    end

    # Combine the 3 address line attributes into a single street attribute.  Magento stores street addresses lines as a
    # single attribute that uses line breaks to differentiate the lines.
    #
    # @return [void]
    def implode_street_address
      street = []
      street << self.address1 unless self.address1.blank?
      street << self.address2 unless self.address2.blank?
      street << self.address3 unless self.address3.blank?
      self.street = street.join("\n") unless street.blank?
    end

    # If a sync is required, push the address to Magento.  This is the after save callback method.
    #
    # @return [void]
    def sync_local_to_magento
      if self.sync_needed
        self.push
        self.sync_needed = false
        self.save
      end
    end

    # Destroy the address in Magento.  This is the before destroy callback.
    #
    # @return [void]
    def destroy_magento
      unless self.user_address_id.nil?
        API::SOAP::Customer::Address.delete(self.user_address_id)
      end
    end

    # Make sure the user has only one default Address for the type (shipping/billing).
    #
    # @return [void]
    def enforce_single_default
      if self.is_default_billing
        self.user.address_book.where('id != ?', self.id).update_all(is_default_billing: false)
      end

      if self.is_default_shipping
        self.user.address_book.where('id != ?', self.id).update_all(is_default_shipping: false)
      end
    end

  end
end