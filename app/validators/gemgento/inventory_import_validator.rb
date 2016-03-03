module Gemgento
  class InventoryImportValidator < ActiveModel::Validator

    def validate(record)
      @record = record

      begin
        @record.spreadsheet
      rescue Exception => e
        Rails.logger.error e.message
        @record.errors[:file] = 'Invalid Spreadsheet'
        return
      end

      validate_required_attributes
      validate_sku
      validate_attributes
    end

    def validate_required_attributes
      errors = []
      %w[sku quantity manage_stock is_in_stock].each do |attribute|
        errors << attribute unless @record.header_row.include? attribute
      end

      unless errors.empty?
        error = '<b>The following required attributes could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file]= "<div>#{error}</div>"
      end
    end

    def validate_sku
      errors = []

      @record.content_index_range.each do |index|
        row = @record.spreadsheet.row(index)
        sku = row[@record.header_row.index('sku').to_i].to_s.strip
        next if sku.blank?

        errors << sku unless product = Gemgento::Product.not_deleted.find_by(sku: sku)
      end

      unless errors.empty?
        error = '<b>The following SKU(s) could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file]= "<div>#{error}</div>"
      end
    end

    def validate_attributes
      errors = []

      @record.header_row.each do |attribute|
        next if attribute == 'sku'
        errors << attribute unless Gemgento::Inventory.column_names.include? attribute
      end

      unless errors.empty?
        error = '<b>The following inventory attributes could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file]= "<div>#{error}</div>"
      end
    end

  end
end