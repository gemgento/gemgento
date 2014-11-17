module Gemgento
  class ImageImportValidator < ActiveModel::Validator

    def validate(record)
      @record = record
      open_spreadsheet

      if @spreadsheet.nil?
        @record.errors[:spreadsheet] = 'Spreadsheet is required'
      else
        validate_sku
        validate_images
        validate_image_types
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

    def validate_sku
      errors = []

      1.upto @spreadsheet.last_row_index do |index|
        row = @spreadsheet.row(index)
        sku = row[@headers.index('sku').to_i].to_s.strip
        next if sku.blank?

        if Gemgento::Product.unscoped.not_deleted.find_by(sku: sku).nil?
          errors << sku
        end
      end

      unless errors.empty?
        error = '<b>The following SKU(s) could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:spreadsheet] = "<div>#{error}</div>"
      end
    end

    def validate_images
      errors = []

      1.upto @spreadsheet.last_row_index do |index|
        row = @spreadsheet.row(index)
        file_name_base = row[@headers.index('image').to_i].to_s.strip
        images_found = false

        @record.image_labels.each do |label|

          @record.image_file_extensions.each do |extension|
            file_name = @record.image_path + file_name_base + '_' + label + extension
            next unless File.exist?(file_name)

            images_found = true
            break
          end

          break if images_found
        end

        unless images_found
          errors << file_name_base unless errors.include? file_name_base
        end
      end

      unless errors.empty?
        error = '<b>The following image(s) could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:spreadsheet] << "<div>#{error}</div>"
      end
    end

    def validate_image_types
      errors = []

      @record.image_types.each do |image_type|
        next if image_type.blank?

        asset_type = Gemgento::AssetType.find_by(code: image_type)
        errors << image_type if asset_type.nil?
      end

      unless errors.empty?
        error = '<b>The following image type(s) could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:image_types_raw] << "<div>#{error}</div>"
      end
    end

  end
end