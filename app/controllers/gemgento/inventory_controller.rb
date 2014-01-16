module Gemgento
  class InventoryController < BaseController

    def update
      data = params[:data]

      product = Gemgento::Product.find_by(magento_id: data[:product_id])

      data[:inventories].each do |store_id, stock_data|
        store = Gemgento::Store.find_by(magento_id: store_id)
        inventory = Gemgento::Inventory.find_or_initialize_by(store: store, product: product)

        inventory.product = product
        inventory.store = store
        inventory.quantity = stock_data[:qty]
        inventory.is_in_stock = stock_data[:is_in_stock]
        inventory.sync_needed = false
        inventory.save
      end

      render nothing: true
    end

  end
end