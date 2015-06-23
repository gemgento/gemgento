module Gemgento

  # @author Gemgento LLC
  class ProductCategory < ActiveRecord::Base
    belongs_to :product
    belongs_to :category
    belongs_to :store

    validates :product, :category, :store, presence: true
    validates :product, uniqueness: { scope: [:category, :store] }

    default_scope -> { order(:category_id, :position, :product_id, :id) }

    before_save :update_magento_category_product, if: -> { sync_needed }
    after_save :touch_product, :touch_category, if: -> { changed? }
    after_destroy :touch_category, :touch_product

    private

    def touch_product
      TouchProduct.perform_async([self.product.id]) if self.product
    end

    def touch_category
      category_ids = [self.category_id]
      category_ids += self.product.categories.pluck(:id) if self.product
      TouchCategory.perform_async(category_ids)
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