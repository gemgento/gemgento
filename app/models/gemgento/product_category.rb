module Gemgento
  class ProductCategory < ActiveRecord::Base
    belongs_to :product
    belongs_to :category
    belongs_to :store

    default_scope -> { where(store: Gemgento::Store.current).order(:position) }

    after_save :touch_product

    private

    def touch_product
      Gemgento::TouchProduct.perform_async([self.product.id]) if self.changed?
    end
  end
end