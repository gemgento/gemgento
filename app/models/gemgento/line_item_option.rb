module Gemgento

  # @author Gemgento LLC
  class LineItemOption < ActiveRecord::Base
    belongs_to :line_item, class_name: 'Gemgento::LineItem'
    belongs_to :bundle_item, class_name: 'Gemgento::Bundle::Item'

    validates :bundle_item, uniqueness: { scope: :line_item }
  end
end