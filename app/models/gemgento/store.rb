module Gemgento
  class Store < ActiveRecord::Base
    has_many :products
    has_many :users

    def self.index
      if Store.find(:all).size == 0
        fetch_all
      end

      Store.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:store_list)

      unless response[:stores][:item].is_a? Array
        response[:stores][:item] = [response[:stores][:item]]
      end

      response[:stores][:item].each do |store|
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
      store.sort_order = source[:sort_order]
      store.is_active = source[:is_active]
      store.save
    end
  end
end