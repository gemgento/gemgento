module Gemgento
  module Bundle

    # @author Gemgento LLC
    class Item < ActiveRecord::Base
      enum price_type: { fixed: 0, percent: 1 }

      belongs_to :option, class_name: 'Gemgento::Bundle::Option', foreign_key: :bundle_option_id
      belongs_to :product, class_name: 'Gemgento::Product'

      validates :option, :product, presence: true
      validates :product, uniqueness: { scope: :product }
    end
  end
end