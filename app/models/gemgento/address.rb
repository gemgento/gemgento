module Gemgento

  # @author Gemgento LLC
  class Address < ActiveRecord::Base
    belongs_to :addressable, polymorphic: true, class_name: 'Gemgento::Address'
    belongs_to :country, class_name: 'Gemgento::Country'
    belongs_to :region, class_name: 'Gemgento::Region'

    has_one :shopify_adapter, class_name: 'Adapter::ShopifyAdapter', as: :gemgento_model

    attr_accessor :address1, :address2, :address3, :copy_to_user

    validates :region, presence: true, if: -> { !country.nil? && !country.regions.empty? }
    validates_uniqueness_of :addressable_id,
                            scope: [:addressable_type, :street, :city, :country, :region, :postcode, :telephone],
                            message: 'address is not unique',
                            if: -> { addressable_type == 'Gemgento::User' }

    after_find :explode_street_address
    before_validation :strip_whitespace, :implode_street_address

    before_create :create_magento_address, if: -> { is_addressable_user? && magento_id.nil? }
    before_update :update_magento_address, if: -> { is_addressable_user? && !magento_id.nil? && sync_needed? }
    before_destroy :destroy_magento_address, if: -> { is_addressable_user? && !magento_id.nil? }

    after_save :enforce_single_default, if: -> { is_addressable_user? }
    after_save :copy_from_addressable_to_user, if: -> { copy_to_user && addressable && addressable.try(:user) }

    default_scope -> { order(is_billing: :desc, is_shipping: :desc, updated_at: :desc) }

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

    # Duplicate address from addressable user to user.
    #
    # @return [Gemgento::Address] the newly created Address.
    def copy_from_addressable_to_user
      address = duplicate
      address.addressable = addressable.user
      address.is_billing = self.is_billing
      address.is_shipping = self.is_shipping
      address.save

      return address
    end

    # Set the street attribute.  Override required to explode the street into address lines.
    def street=(value)
      super
      explode_street_address
    end

    def is_addressable_user?
      addressable && addressable.is_a?(Gemgento::User)
    end

    # Duplicate an address.  Different from dup because it avoids unique magento attributes and includes
    # country and region associations.
    #
    # @return [Gemgento::Address] newly duplicated address
    def duplicate
      address = self.dup
      address.region = self.region
      address.country = self.country
      address.addressable = nil
      address.is_billing = false
      address.is_shipping = false
      address.increment_id = nil
      address.sync_needed = false
      address.magento_id = nil

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
      return if self.street.nil?

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

    # Create an associated address in Magento.
    #
    # @return [Boolean]
    def create_magento_address
      response = API::SOAP::Customer::Address.create(self)
      if response.success?
        self.magento_id = response.body[:result]
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Update associated address in Magento.
    #
    # @return [Boolean]
    def update_magento_address
      response = API::SOAP::Customer::Address.update(self)
      if response.success?
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Destroy the address in Magento.  This is the before destroy callback.
    #
    # @return [void]
    def destroy_magento_address
      response = API::SOAP::Customer::Address.delete(self.magento_id)

      if response.success?
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Make sure the user has only one default Address for the type (shipping/billing).
    #
    # @return [void]
    def enforce_single_default
      if self.is_billing
        self.addressable.addresses.where('id != ?', self.id).update_all(is_billing: false)
      end

      if self.is_shipping
        self.addressable.addresses.where('id != ?', self.id).update_all(is_shipping: false)
      end
    end

  end
end