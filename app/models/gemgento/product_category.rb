module Gemgento
  class ProductCategory < ActiveRecord::Base
    belongs_to :product
    belongs_to :category
    belongs_to :store

    validates :product_id, :category_id, :store_id, presence: true

    default_scope -> { order(:category_id, :position, :product_id, :id) }

    after_save :sync_local_to_magento, :touch_product

    private

    def touch_product
      TouchProduct.perform_async([self.product.id]) if self.changed?
    end

    def sync_local_to_magento
      if self.sync_needed
        API::SOAP::Catalog::Category.update_product(self)
        self.sync_needed = false
        self.save
      end
    end
  end
end