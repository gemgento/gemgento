module Gemgento
  module API
    module SOAPv2
      module Miscellaneous
        class Store

          def self.fetch_all
            list.each do |store|
              sync_magento_to_local(store)
            end
          end

          def self.list
            response = Gemgento::Magento.create_call(:store_list)

            unless response[:stores][:item].is_a? Array
              response[:stores][:item] = [response[:stores][:item]]
            end

            response[:stores][:item]
          end

          def self.info
            response = Gemgento::Magento.create_call(:store_list)
            response[:result]
          end

          private

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source)
            store = Gemgento::Store.find_or_initialize_by(magento_id: source[:store_id])
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