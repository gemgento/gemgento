require 'spreadsheet'
require 'open-uri'

module Gemgento

  # @author Gemgento LLC
  class InventoryImport < ActiveRecord::Base
    include ActiveModel::Validations

    has_attached_file :spreadsheet

    serialize :import_errors, Array

    validates_attachment_content_type :spreadsheet, content_type: ['application/vnd.ms-excel']
    validates_with InventoryImportValidator

    after_commit :process

    # Check if any InventoryImport is active.
    #
    # @return [Boolean]
    def self.is_active?
      InventoryImport.where(is_active: true).count > 0
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
      @stores = Store.all

      1.upto @worksheet.last_row_index do |index|
        puts "Working on row #{index}"
        @row = @worksheet.row(index)
        sku = @row[@headers.index('sku').to_i].to_s.strip
        next if sku.blank?

        @product = Product.not_deleted.find_by(sku: sku)
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
        inventory = Inventory.find_or_initialize_by(product: @product, store: store)

        @headers.each_with_index do |attribute, index|
          next if attribute == 'sku'
          eval("inventory.#{attribute} = #{@row[index]}")
        end

        inventory.sync_needed = true
        inventory.save
      end
    end

  end
end