module Gemgento
  class PriceTier < ActiveRecord::Base

    belongs_to :store, class_name: 'Gemgento::Store'
    belongs_to :product, class_name: 'Gemgento::Product'
    belongs_to :user_group, class_name: 'Gemgento::UserGroup'

    validates :store, :product, :quantity, :price, presence: true

    after_save :touch_product, if: -> { changed? }

    private

    def touch_product
      TouchProduct.perform_async(self.product.id, true)
    end

  end
end