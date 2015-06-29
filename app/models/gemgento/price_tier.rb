module Gemgento
  class PriceTier < ActiveRecord::Base

    belongs_to :store, class_name: 'Gemgento::Store'
    belongs_to :product, class_name: 'Gemgento::Product'
    belongs_to :user_group, class_name: 'Gemgento::UserGroup'

    validates :store, :product, :quantity, :price, presence: true

    after_save :touch_product, if: -> { changed? }

    # Check if PriceTier is valid for the given quantity and user.
    #
    # @param quantity [Float]
    # @param user_group [Gemgento::UserGroup]
    def is_valid?(quantity, user_group)
      return quantity >= self.quantity && user_group == self.user_group
    end

    # @param product [Gemgento::Product]
    def self.calculate_price(product, quantity = 1.0, user = nil, store = nil)
      store = Gemgento::Store.current if store.nil?
      price = product.attribute_value('price', store).to_f
      user_group = user.nil? ? UserGroup.find_by(magento_id: 0) : user.user_group

      product.price_tiers.where(store: store).each do |price_tier|
        next unless price_tier.is_valid? quantity, user_group
        price = price_tier.price if price_tier.price < price
      end

      return price
    end

    private

    def touch_product
      TouchProduct.perform_async(self.product.id, true)
    end

  end
end