module Gemgento
  module ProductTouches
    extend ActiveSupport::Concern

    included do
      has_many :bundle_items, through: :product, class_name: 'Gemgento::Bundle::Item'
      has_many :configurable_products, through: :product, class_name: 'Gemgento::Product'

      touch :bundle_items, after_touch: :after_touch
      touch :categories, if: Proc.new { |record| record.product.present? }, after_touch: :after_touch
      touch :configurable_products, after_touch: :after_touch
      touch :product, after_touch: :after_touch

      # explicit association needed to avoid mysql error with a 'double through' association
      #   "Mysql2::Error: You can't specify target table 'gemgento_categories' for update in FROM clause"
      def categories
        self.product.categories if self.product
      end

      def after_touch
        # do nothing, placeholder
      end
    end

  end
end