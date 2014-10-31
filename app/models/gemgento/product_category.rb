module Gemgento
  class ProductCategory < ActiveRecord::Base
    belongs_to :product
    belongs_to :category
    belongs_to :store

    validates :product_id, :category_id, :store_id, presence: true

    default_scope -> { order(:category_id, :position, :product_id, :id) }

    before_save :update_magento_category_product, if: -> { sync_needed }
    after_save :touch_product

    private

    def touch_product
      TouchProduct.perform_async([self.product.id]) if self.changed?
    end

    def update_magento_category_product
      response = API::SOAP::Catalog::Category.update_product(self)

      if response.success?
        self.sync_needed = false
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end
  end
end