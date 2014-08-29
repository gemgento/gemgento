module Gemgento
  class InventoryImportValidator < ActiveModel::Validator

    def validate(record)
      @record = record
      open_spreadsheet

      if @spreadsheet.nil?
        @record.errors[:spreadsheet] = 'Spreadsheet is required'
      else
        validate_required_attributes
        validate_sku
        validate_attributes
      end
    end

    def open_spreadsheet
      if @record.spreadsheet.queued_for_write[:original].nil? || @record.spreadsheet_file_name.nil?
        @spreadsheet = nil
      else
        @spreadsheet = Spreadsheet.open(open(@record.spreadsheet.queued_for_write[:original].path)).worksheet(0)
        @headers = []

        @spreadsheet.row(0).each do |h|
          unless h.nil?
            @headers << h.downcase.gsub(' ', '_').strip
          end
        end
      end
    end

    def validate_required_attributes
      errors = []
      %w[sku quantity manage_stock is_in_stock].each do |attribute|
        errors << attribute unless @headers.include? attribute
      end

      unless errors.empty?
        error = '<b>The following required attributes could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:spreadsheet] = "<div>#{error}</div>"
      end
    end

    def validate_sku
      errors = []

      1.upto @spreadsheet.last_row_index do |index|
        row = @spreadsheet.row(index)
        sku = row[@headers.index('sku').to_i].to_s.strip
        errors << sku unless product = Gemgento::Product.not_deleted.find_by(sku: sku)
      end

      unless errors.empty?
        error = '<b>The following SKU(s) could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:spreadsheet] = "<div>#{error}</div>"
      end
    end

    def validate_attributes
      errors = []

      @headers.each do |attribute|
        next if attribute == 'sku'
        errors << attribute unless Gemgento::Inventory.column_names.include? attribute
      end

      unless errors.empty?
        error = '<b>The following inventory attributes could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:spreadsheet] = "<div>#{error}</div>"
      end
    end

  end
end