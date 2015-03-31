module Gemgento
  module Magento
    class StoresController < Gemgento::Magento::BaseController
      def update
        data = params[:data]

        @store = Store.find_or_initialize_by(magento_id: data[:store_id])
        @store.magento_id = source[:store_id]
        @store.code = source[:code]
        @store.website_id = source[:website_id]
        @store.group_id = source[:group_id]
        @store.name = source[:name]
        @store.sort_order = source[:sort_order]
        @store.is_active = source[:is_active]
        @store.save

        render nothing: true
      end
    end
  end
end