module Gemgento

  # @author Gemgento LLC
  class Tag < ActiveRecord::Base
    has_many :store_tags, class_name: 'StoreTag'
    has_many :stores, through: :store_tags

    has_and_belongs_to_many :products, class_name: 'Product', join_table: 'gemgento_products_tags'

    validates :name, uniqueness: true

    before_save :create_magento_tag, if: -> { sync_needed? && magento_id.nil? }
    before_save :update_magento_tag, if: -> { sync_needed? && !magento_id.nil? }

    # Get the tag base popularity for a store.
    #
    # @param store [Store, nil]
    # @return [Integer]
    def base_popularity(store = nil)
      self.store_tags.find_by(store: (store || self.stores.first)).base_popularity
    end

    private

    # Create assocaited Magento Tag.
    #
    # @return [Boolean]
    def create_magento_tag
      response = API::SOAP::Catalog::ProductTag.manage(self, stores.first)

      if response.success?
        self.magento_id = response.body[:result]
        self.sync_needed = false

        stores.each_with_index do |store, i|
          next if i == 0
          response = API::SOAP::Catalog::ProductTag.manage(self, store)
          self.sync_needed = true unless response.success?
        end

        return true
      else
        return false
      end
    end

    # Update associated Magento Tag.
    #
    # @return [Boolean]
    def update_magento_tag
      self.stores.each do |store|
        response = API::SOAP::Catalog::ProductTag.manage(self, store)

        unless response.success?
          errors.add(:base, response.body[:faultstring])
          return false
        end
      end

      self.sync_needed = false
      return true
    end
  end
end