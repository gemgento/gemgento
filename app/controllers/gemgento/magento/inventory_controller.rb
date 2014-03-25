module Gemgento
  class Magento::InventoryController < MagentoController

    def update
      data = params[:data]

      product = Gemgento::Product.find_by(magento_id: data[:product_id])
      default_values = nil

      if !product.nil? && !data[:inventories].nil?
        data[:inventories].each do |website_id, stock_data|
          store = Gemgento::Store.find_by(website_id: website_id)
          next if stock_data[:qty].nil?

          if store.nil?
            default_values = stock_data
            next
          end

          inventory = Gemgento::Inventory.find_or_initialize_by(store: store, product: product)
          inventory.product = product
          inventory.store = store
          inventory.quantity = stock_data[:qty]
          inventory.is_in_stock = stock_data[:is_in_stock]
          inventory.use_default_website_stock = stock_data[:use_default_website_stock].nil? ? true : stock_data[:use_default_website_stock]
          inventory.sync_needed = false
          inventory.save
        end

        # loop through to set default values
        unless default_values.nil?
          product.inventories.where(use_default_website_stock: true).each do |inventory|
            inventory.quantity = default_values[:qty]
            inventory.is_in_stock = default_values[:is_in_stock]
            inventory.sync_needed = false
            inventory.save
          end
        end
      end

      render nothing: true
    end

  end
end