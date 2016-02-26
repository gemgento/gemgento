module Gemgento
  class ProductImportValidator < ActiveModel::Validator

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

      validate_unique_skus
      validate_required_attribute_codes
      validate_valid_attribute_codes
      validate_categories
      validate_images
    end

    def validate_unique_skus
      errors = []
      skus = []

      @record.content_index_range.each do |index|
        row = @record.spreadsheet.row(index)
        sku = row[@record.header_row.index('sku').to_i].to_s.strip

        next if sku.blank? # skip blank skus

        if skus.include? sku
          errors << sku
        else
          skus << sku
        end
      end

      unless errors.empty?
        error = '<b>The following SKU(s) are not unique:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file] = "<div>#{error}</div>"
      end
    end

    def validate_required_attribute_codes
      errors = []
      required_attributes = %w[magento_type sku status weight]
      (required_attributes << @record.configurable_attributes.pluck(:code)).flatten!
      required_attributes << 'image' if @record.include_images?

      required_attributes.each do |attribute_code|
        if attribute_code != '' && !attribute_code.nil? && !@record.header_row.include?(attribute_code)
          errors << attribute_code
        end
      end

      unless errors.empty?
        error = '<b>The following required attribute code(s) were not found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file] = "<div>#{error}</div>"
      end
    end

    def validate_valid_attribute_codes
      errors = []
      default_attributes = %w[magento_type sku status image visibility category]

      @record.header_row.each do |attribute_code|
        next if default_attributes.include? attribute_code

        unless @record.product_attribute_set.product_attributes.exists?(code: attribute_code)
          errors << attribute_code
        end
      end

      unless errors.empty?
        error = '<b>The following attribute code(s) are unknown:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file] = "<div>#{error}</div>"
      end
    end

    def validate_categories
      errors = []

      @record.content_index_range.each do |index|
        row = @record.spreadsheet.row(index)
        categories = row[@record.header_row.index('category').to_i].to_s.strip.split('&')

        categories.each do |category_string|
          category_string.strip!
          subcategories = category_string.split('>')
          parent = @record.root_category

          subcategories.each do |category_url_key|
            category_url_key.strip!
            category =  Gemgento::Category.find_by(url_key: category_url_key, parent_id: parent.id)

            if category.nil?
              errors << category_url_key unless errors.include? category_url_key
            else
              parent = category
            end
          end
        end
      end

      unless errors.empty? || errors[0] == ""
        error = '<b>The following category url key(s) could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file] << "<div>#{error}</div>"
      end
    end

    def validate_images
      return unless @record.include_images?
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

      unless errors.empty? || errors[0] == ""
        error = '<b>The following image(s) could not be found:</b><br /><ul><li>'
        error += errors.join('</li><li>')
        error += '</li></ul>'

        @record.errors[:file] << "<div>#{error}</div>"
      end
    end

  end
end