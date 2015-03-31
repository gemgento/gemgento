module Gemgento
  module Magento
    class InventoryController < Gemgento::Magento::BaseController

      def update
        data = params[:data]

        @product = Product.find_by(magento_id: data[:product_id])
        default_values = nil

        if !@product.nil? && !data[:inventories].nil?

          # If stock data for only one website was pushed, and the website id is 0, rails thinks data[:inventories]
          # is an array and not a hash, so make it a Hash
          data[:inventories] = { 0 => data[:inventories][0] } if data[:inventories].is_a? Array

          data[:inventories].each do |website_id, stock_data|

            store = Store.find_by(website_id: website_id.blank? ? nil : website_id)
            next if stock_data[:qty].nil?

            if store.nil?
              default_values = stock_data
              next
            end

            inventory = Inventory.find_or_initialize_by(store: store, product: @product)
            inventory.product = @product
            inventory.store = store
            inventory.quantity = stock_data[:qty]
            inventory.is_in_stock = stock_data[:is_in_stock]
            inventory.use_default_website_stock = stock_data[:use_default_website_stock].nil? ? true : stock_data[:use_default_website_stock]
            inventory.backorders = stock_data[:backorders].to_i
            inventory.use_config_backorders = stock_data[:use_config_backorders]
            inventory.min_qty = stock_data[:min_qty].to_i
            inventory.use_config_min_qty = stock_data[:use_config_min_qty]
            inventory.manage_stock = stock_data[:manage_stock]
            inventory.sync_needed = false
            inventory.save
          end

          # loop through to set default values
          unless default_values.nil?
            @product.inventories.where(use_default_website_stock: true).each do |inventory|
              inventory.quantity = default_values[:qty]
              inventory.is_in_stock = default_values[:is_in_stock]
              inventory.backorders = default_values[:backorders].to_i
              inventory.use_config_backorders = default_values[:use_config_backorders]
              inventory.min_qty = default_values[:min_qty].to_i
              inventory.use_config_min_qty = default_values[:use_config_min_qty]
              inventory.manage_stock = default_values[:manage_stock]
              inventory.sync_needed = false
              inventory.save
            end
          end
        end

        render nothing: true
      end

    end
  end
end