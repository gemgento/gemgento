module Gemgento
  class InventoryController < BaseController

    def update
      data = params[:data]

      product = Gemgento::Product.find_by(magento_id: data[:product_id])

      if !product.nil? && !data[:inventories].nil?
        data[:inventories].each do |website_id, stock_data|
          store = Gemgento::Store.find_by(website_id: website_id)
          next if store.nil? || stock_data[:qty].nil?

          inventory = Gemgento::Inventory.find_or_initialize_by(store: store, product: product)
          inventory.product = product
          inventory.store = store
          inventory.quantity = stock_data[:qty]
          inventory.is_in_stock = stock_data[:is_in_stock]
          inventory.use_default_website_stock = stock_data[:use_default_website_stock].nil? ? true : stock_data[:use_default_website_stock]
          inventory.sync_needed = false
          inventory.save
        end
      end

      render nothing: true
    end

  end
end