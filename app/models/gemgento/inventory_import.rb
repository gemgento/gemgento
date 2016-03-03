require 'spreadsheet'
require 'open-uri'

module Gemgento

  # @author Gemgento LLC
  class InventoryImport < Import
    attr_accessor :product

    validates_with InventoryImportValidator, on: :create

    # Set the Inventory for a Product.
    #
    # @return [Void]
    def process_row
      self.product = Gemgento::Product.not_deleted.find_by(sku: row[header_row.index('sku').to_i])

      return if self.product.magento_type == 'configurable'
      Gemgento::Store.all.each do |store|
        inventory = self.product.inventories.find_or_initialize_by(store: store)

        inventory.use_config_manage_stock = true
        inventory.use_config_backorders = true
        inventory.use_config_min_qty = true

        header_row.each_with_index do |attribute, index|
          next unless Gemgento::Inventory.column_names.include?(attribute)

          value = value(row[index], Gemgento::Inventory.columns_hash[attribute].type)
          inventory.assign_attributes(attribute => value)
        end

        inventory.sync_needed = true

        unless inventory.save
          self.process_errors << "Row ##{current_row}: #{inventory.errors[:base]}"
        end
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
      retries ||= 0
      if retries += 1 <= @stores.count
        retry
      else
        self.process_errors << "Row ##{current_row}: #{e.message}"
      end
    rescue Exception => e
      self.process_errors << "Row ##{current_row}: #{e.message}"
    end

  end
end