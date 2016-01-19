module Gemgento
  class PriceTier < ActiveRecord::Base

    belongs_to :store, class_name: 'Gemgento::Store'
    belongs_to :product, class_name: 'Gemgento::Product'
    belongs_to :user_group, class_name: 'Gemgento::UserGroup'

    touch :product

    validates :store, :product, :quantity, :price, presence: true

    # Check if PriceTier is valid for the given quantity and user.
    #
    # @param quantity [Float]
    # @param user_group [Gemgento::UserGroup]
    def is_valid?(quantity, user_group)
      return quantity >= self.quantity && (self.user_group.nil? || user_group == self.user_group)
    end

    # @param product [Gemgento::Product]
    # @param quantity [Float]
    # @param user_group [Gemgento::UserGroup]
    def self.calculate_price(product, quantity = 1.0, user_group = nil, store = nil)
      store ||= Gemgento::Store.current
      price = product.attribute_value('price', store).to_f
      user_group ||= UserGroup.find_by(magento_id: 0)

      product.price_tiers.where(store: store).where('quantity <= ?', quantity).each do |price_tier|
        next unless price_tier.is_valid? quantity, user_group
        price = price_tier.price if price_tier.price < price
      end

      return price
    end

  end
end