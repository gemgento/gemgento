require 'spreadsheet'
require 'open-uri'

module Gemgento
  class InventoryImport < ActiveRecord::Base
    include ActiveModel::Validations

    has_attached_file :spreadsheet

    serialize :import_errors, Array

    validates_with Gemgento::InventoryImportValidator

    after_commit :process

    def self.is_active?
      Gemgento::InventoryImport.where(is_active: true).count > 0
    end

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
        puts "Working on row #{index}"
        @row = @worksheet.row(index)
        @product = Gemgento::Product.not_deleted.find_by(sku: @row[@headers.index('sku').to_i].to_s.strip)
        set_inventory
      end

      Gemgento::InventoryImport.skip_callback(:commit, :after, :process)
      self.save validate: false
      Gemgento::InventoryImport.set_callback(:commit, :after, :process)
    end

    private

    def get_headers
      accepted_headers = []

      @worksheet.row(0).each do |h|
        unless h.nil?
          accepted_headers << h.downcase.gsub(' ', '_').strip
        end
      end

      accepted_headers
    end

    def set_inventory
      @stores.each do |store|
        inventory = Gemgento::Inventory.find_or_initialize_by(product: @product, store: store)

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