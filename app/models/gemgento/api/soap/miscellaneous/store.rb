module Gemgento
  module API
    module SOAP
      module Miscellaneous
        class Store

          def self.fetch_all
            list.each do |store|
              sync_magento_to_local(store)
            end
          end

          def self.list
            response = Gemgento::Magento.create_call(:store_list)

            if response.success?
              unless response.body[:stores][:item].is_a? Array
                response.body[:stores][:item] = [response.body[:stores][:item]]
              end

              response.body[:stores][:item]
            end
          end

          def self.info
            response = Gemgento::Magento.create_call(:store_list)

            if response.success?
              response.body[:result]
            end
          end

          private

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source)
            store = Gemgento::Store.where(magento_id: source[:store_id]).first_or_initialize
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
    end
  end
end