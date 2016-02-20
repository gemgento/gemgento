module Gemgento
  module ProductTouches
    extend ActiveSupport::Concern

    included do
      has_many :bundle_items, through: :product, class_name: 'Gemgento::Bundle::Item'
      has_many :configurable_products, through: :product, class_name: 'Gemgento::Product'

      touch :bundle_items
      touch :categories, if: Proc.new { |record| record.product.present? }
      touch :configurable_products
      touch :product

      # explicit association needed to avoid mysql error with a 'double through' association
      #   "Mysql2::Error: You can't specify target table 'gemgento_categories' for update in FROM clause"
      def categories
        self.product.categories
      end
    end

  end
end