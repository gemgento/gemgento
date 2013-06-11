module Gemgento
  class Store < ActiveRecord::Base
    def self.index
      if Store.find(:all).size == 0
        fetch_all
      end

      Store.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:customer_group_list)

      unless response[:result][:item].is_a? Array
        response[:result][:item] = [response[:result][:item]]
      end

      response[:result][:item].each do |store|
        sync_magento_to_local(store)
      end

    end

    private

    # Save Magento store to local
    def self.sync_magento_to_local(source)
      store = Store.find_or_initialize_by(magento_id: source[:store_id])
      store.magento_id = source[:store_id]
      store.code = source[:code]
      store.group_id = source[:group_id]
      store.name = source[:name]
      source.sort_order = source[:sort_order]
      source.is_active = is_active
      store.save
    end
  end
end