module Gemgento
  class ImageImportValidator < ActiveModel::Validator

    def validate(record)
      @record = record

      begin
        @record.spreadsheet
      rescue Exception => e
        Rails.logger.error e.message
        @record.errors[:file] = 'Invalid Spreadsheet'
        return
      end

      @record.set_total_rows
      validate_sku
      validate_images
      validate_image_types
    end

    def validate_sku
      errors = []

      @record.content_index_range.each do |index|
        row = @record.spreadsheet.row(index)
        sku = row[@record.header_row.index('sku').to_i].to_s.strip
        next if sku.blank?

        if Gemgento::Product.unscoped.not_deleted.find_by(sku: sku).nil?
          errors << sku
        end
      end

      unless errors.empty?
        error = '<b>The following SKU(s) could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file] = "<div>#{error}</div>"
      end
    end

    def validate_images
      errors = []

      @record.content_index_range.each do |index|
        row = @record.spreadsheet.row(index)
        file_name_base = row[@record.header_row.index('image').to_i].to_s.strip
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

        @record.errors[:file] << "<div>#{error}</div>"
      end
    end

    def validate_image_types
      errors = []

      @record.image_types.each do |types|
        next if types.empty?

        types.each do |type|
          asset_type = Gemgento::AssetType.find_by(code: type)
          errors << type if asset_type.nil?
        end
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