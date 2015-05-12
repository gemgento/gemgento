module Gemgento
  module Bundle

    # @author Gemgento LLC
    class Option < ActiveRecord::Base
      enum input_type: { selection: 0, radio: 1, checkbox: 2, multi: 3 }

      belongs_to :product, class_name: 'Gemgento::Product'

      has_many :items, class_name: 'Gemgento::Bundle::Item', dependent: :destroy, foreign_key: :bundle_option_id
      has_many :products, through: :items, class_name: 'Gemgento::Product'

      validates :product, presence: true

      after_save :touch_product, if: -> { self.changed? }

      default_scope -> { order :position }

      private

      def touch_product
        TouchProduct.perform_async([self.product.id])
      end
    end
  end
end