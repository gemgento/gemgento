module Gemgento
  class Import < ActiveRecord::Base
    enum state: { pending: 0, processing: 1, complete: 2, failed: 3 }

    has_attached_file :file

    after_initialize :set_default_options,
                     :set_default_process_errors

    before_create :set_total_row

    validates :file, presence: :true
    validates_attachment_content_type :file, content_type: [
      'application/vnd.ms-excel', # .xls
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', # .xlsx
      'application/vnd.ms-excel.sheet.macroEnabled.12', # .xlsm
      'text/csv', # .csv
      'application/vnd.oasis.opendocument.spreadsheet', # .ods
    ]

    serialize :options, Hash
    serialize :process_errors, Array

    def set_default_process_errors
      self.process_errors ||= []
    end

    def set_default_options
      self.options = default_options.merge(self.options || {})
    end

    def default_options
      {}
    end

    def spreadsheet
      @spreadsheet ||= Roo::Spreadsheet.open(self.file.path)
    end

    def set_total_row
      Rails.logger.debug spreadsheet.info
      self.total_rows = spreadsheet.info[:rows].size
    end

    # Dynamic option value getter/setter
    def method_missing(method, *args)
      Rails.logger.debug "Gemgento::Import - Missing Method: #{method}"
      Rails.logger.debug "Possible Keys: #{self.options.keys}"
      if self.options.has_key?(method.to_sym)
        name = method.to_s

        if name.include?('=')
          return self.options[method.to_sym] = args.first
        else
          return self.options[method.to_sym]
        end
      end

      super
    end

  end
end
