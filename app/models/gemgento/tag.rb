module Gemgento
  class Tag < ActiveRecord::Base
    has_many :store_tags, class_name: 'StoreTag'
    has_many :stores, through: :store_tags

    has_and_belongs_to_many :products, class_name: 'Product', join_table: 'gemgento_products_tags'

    validates :name, uniqueness: true

    before_save :magento_magento_tag, if: -> { magento_id.nil? || sync_needed }

    # Get the tag base popularity for a store.
    #
    # @param store [Store, nil]
    # @return [Integer]
    def base_popularity(store = nil)
      self.store_tags.find_by(store: (store || self.stores.first)).base_popularity
    end

    private

    # Synchronize a Gemgento Tag with Magento.
    #
    # @return [Boolean]
    def sync_local_to_magento
      self.stores.each do |store|
        response = API::SOAP::Catalog::ProductTag.manage(self, store)

        if response.success?
          self.magento_id = response.body[:result]
        else
          errors.add(:base, response.body[:faultstring])
          return false
        end

        self.sync_needed = false
        return true
      end
    end
  end
end