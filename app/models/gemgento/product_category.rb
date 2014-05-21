module Gemgento
  class ProductCategory < ActiveRecord::Base
    belongs_to :product
    belongs_to :category
    belongs_to :store

    validates :product_id, :category_id, :store_id, presence: true

    default_scope -> { order(:position) }

    after_save :touch_product
    after_update :sync_local_to_magento

    private

    def touch_product
      Gemgento::TouchProduct.perform_async([self.product.id]) if self.changed?
    end

    def sync_local_to_magento
      if self.sync_needed
        Gemgento::API::SOAP::Catalog::Category.update_product(self)
        self.sync_needed = false
        self.save
      end
    end
  end
end