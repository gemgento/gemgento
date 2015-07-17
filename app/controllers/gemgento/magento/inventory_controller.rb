module Gemgento
  module Magento
    class InventoryController < Gemgento::Magento::BaseController

      def update
        data = params[:data]

        @product = Gemgento::Product.find_by!(magento_id: data[:product_id])

        @product.stores.each do |store|
            inventory = Gemgento::Inventory.find_or_initialize_by(store: store, product: @product)
            inventory.product = @product
            inventory.store = store
            inventory.quantity = data[:qty]
            inventory.is_in_stock = data[:is_in_stock]
            inventory.backorders = data[:backorders].to_i
            inventory.use_config_backorders = data[:use_config_backorders]
            inventory.min_qty = data[:min_qty].to_i
            inventory.use_config_min_qty = data[:use_config_min_qty]
            inventory.manage_stock = data[:manage_stock]
            inventory.sync_needed = false
            inventory.save
        end

        render nothing: true
      end

    end
  end
end