module Gemgento
  class Import < ActiveRecord::Base
    enum state: { pending: 0, processing: 1, complete: 2, failed: 3 }

    has_attached_file :file

    after_initialize :set_default_options,
                     :set_default_process_errors

    before_create :set_total_rows

    after_commit :process_later, if: Proc.new { |r| r.transaction_include_any_action?([:create]) }

    validates :file, presence: :true
    validates_attachment_content_type :file, content_type: [
      'application/vnd.ms-excel', # .xls
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', # .xlsx
      'application/vnd.ms-excel.sheet.macroEnabled.12', # .xlsm
      'text/csv', # .csv
      'application/vnd.oasis.opendocument.spreadsheet', # .ods
    ]

    attr_accessor :spreadsheet, :header_row, :row

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
      self.total_rows = spreadsheet.last_row - spreadsheet.first_row
    end

    def percentage_complete
      (current_row / total_rows) * 100
    end

    def spreadsheet
      @spreadsheet ||= begin
        if self.new_record?
          Roo::Spreadsheet.open(self.file.queued_for_write[:original].path).sheet(0)
        else
          Roo::Spreadsheet.open(File.open(self.file.path)).sheet(0)
        end
      end
    end

    def header_row
      @header_row ||= spreadsheet.row spreadsheet.first_row
    end

    def process
      Rails.logger.debug "Start #{self.class}.process"
      Rails.logger.debug "  header_row: #{self.header_row}"

      self.current_row = spreadsheet.first_row
      self.processing!

      while self.current_row < self.total_rows do
        self.current_row += 1

        self.row = spreadsheet.row(self.current_row + spreadsheet.first_row)
        Rails.logger.debug "  Working on Row #{self.current_row} - #{self.row}"

        self.process_row
        self.save!
      end

      self.complete!

      Rails.logger.debug "Complete #{self.class}.process"

    rescue Exception => e
      self.process_errors << e.message
      self.failed!
      raise
    end

    def process_later
      Gemgento::ImportJob.perform_later(self)
    end

    # @return [Range]
    def content_index_range
      ((spreadsheet.first_row + 1)..spreadsheet.last_row)
    end

  end
end
