module Gemgento
  class Tag < ActiveRecord::Base
    has_many :store_tags, class_name: 'Gemgento::StoreTag'
    has_many :stores, through: :store_tags

    has_and_belongs_to_many :products, class_name: 'Gemgento::Product', join_table: 'gemgento_products_tags'

    after_save :sync_local_to_magento

    # Get the tag base popularity for a store.
    #
    # @param store [Gemgento::Store, nil]
    # @return [Integer]
    def base_popularity(store = nil)
      self.store_tags.find_by(store: (store || self.stores.first)).base_popularity
    end

    private

    # Synchronize a Gemgento Tag with Magento.
    #
    # @return [Void]
    def sync_local_to_magento
      if self.sync_needed?
        self.stores.each do |store|
          Gemgento::API::SOAP::Catalog::ProductTag.manage(self, store)
        end
      end
    end
  end
end