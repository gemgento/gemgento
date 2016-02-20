require 'spreadsheet'
require 'open-uri'

module Gemgento

  # @author Gemgento LLC
  class InventoryImport < ActiveRecord::Base
    include ActiveModel::Validations

    has_attached_file :spreadsheet

    serialize :import_errors, Array

    do_not_validate_attachment_file_type :spreadsheet
    validates_with InventoryImportValidator

    after_commit :process

    # Check if any InventoryImport is active.
    #
    # @return [Boolean]
    def self.is_active?
      Gemgento::InventoryImport.where(is_active: true).count > 0
    end

    # Import all inventories from the spreadsheet.
    #
    # @return [Void]
    def process
      self.is_active = false

      if self.spreadsheet.url =~ URI::regexp
        @worksheet = Spreadsheet.open(open(self.spreadsheet.url)).worksheet(0)
      else
        @worksheet = Spreadsheet.open(self.spreadsheet.path).worksheet(0)
      end

      @headers = get_headers
      @stores = Gemgento::Store.all

      1.upto @worksheet.last_row_index do |index|

        Rails.logger.debug "Working on row #{index}"
        @row = @worksheet.row(index)
        sku = @row[@headers.index('sku').to_i].to_s.strip
        next if sku.blank?

        @product = Gemgento::Product.not_deleted.find_by(sku: sku)
        next if @product.magento_type == 'configurable'

        set_inventory
      end

      InventoryImport.skip_callback(:commit, :after, :process)
      self.save validate: false
      InventoryImport.set_callback(:commit, :after, :process)
    end

    private

    # Get the headers row from the spreadsheet.
    #
    # @return [Array(String)]
    def get_headers
      accepted_headers = []

      @worksheet.row(0).each do |h|
        unless h.nil?
          accepted_headers << h.downcase.gsub(' ', '_').strip
        end
      end

      accepted_headers
    end

    # Set the Inventory for a Product.
    #
    # @return [Void]
    def set_inventory
      @stores.each do |store|
        inventory = @product.inventories.find_or_initialize_by(store: store)

        inventory.use_config_manage_stock = true
        inventory.use_config_backorders = true
        inventory.use_config_min_qty = true

        @headers.each_with_index do |attribute, index|
          next unless Gemgento::Inventory.column_names.include?(attribute)

          value = value(@row[index], Gemgento::Inventory.columns_hash[attribute].type)

          Rails.logger.debug " (#{Gemgento::Inventory.columns_hash[attribute].type}) #{attribute} = #{@row[index]}"

          inventory.assign_attributes(attribute => value)
        end

        inventory.sync_needed = true

        unless inventory.save
          self.import_errors << "SKU: #{@product.sku}, ERROR: #{inventory.errors[:base]}"
        end
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
      retries ||= 0
      if retries += 1 <= @stores.count
        retry
      else
        self.import_errors << "SKU: #{@product.sku}, ERROR: #{e.message}"
      end
    rescue Exception => e
      self.import_errors << "SKU: #{@product.sku}, ERROR: #{e.message}"
    end

    def value(raw_value, type)
      case type
        when :boolean
          return raw_value.to_bool
        else
          return raw_value
      end
    end

  end
end