module Gemgento
  class Import < ActiveRecord::Base
    enum state: { pending: 0, processing: 1, complete: 2, failed: 3 }

    has_attached_file :file

    after_initialize :set_default_options,
                     :set_default_process_errors

    before_create :set_total_rows

    validates :file, presence: :true
    validates_attachment_content_type :file, content_type: [
      'application/vnd.ms-excel', # .xls
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', # .xlsx
      'application/vnd.ms-excel.sheet.macroEnabled.12', # .xlsm
      'text/csv', # .csv
      'application/vnd.oasis.opendocument.spreadsheet', # .ods
    ]

    attr_accessor :spreadsheet

    serialize :options, Hash
    serialize :process_errors, Array

    def set_default_process_errors
      self.process_errors ||= []
    end

    def set_default_options
      self.options = default_options.merge(self.options || {})

      self.options.keys.each do |key|
        self.class.send :define_method, key do |*args|
          self.options[key.to_sym]
        end

        self.class.send :define_method, "#{key}=" do |*args|
          self.options[key.to_sym] = args.first
        end
      end
    end

    def default_options
      {}
    end

    def set_total_rows
      @spreadsheet = Roo::Spreadsheet.open(self.file.queued_for_write[:original].path).sheet(0)
      self.total_rows = spreadsheet.last_row - spreadsheet.first_row
    end

    def percentage_complete
      (current_row / total_rows) * 100
    end

  end
end
