module Gemgento
  module Bundle

    # @author Gemgento LLC
    class Item < ActiveRecord::Base
      enum price_type: { fixed: 0, percent: 1 }

      belongs_to :option, class_name: 'Gemgento::Bundle::Option', foreign_key: :bundle_option_id
      belongs_to :product, class_name: 'Gemgento::Product'

      validates :option, :product, presence: true
      validates :product, uniqueness: { scope: :product }

      after_save :touch_product, if: -> { self.changed? }

      private

      def touch_option_product
        TouchProduct.perform_async([self.option.product.id])
      end

    end
  end
end