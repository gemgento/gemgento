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
    # @param user [Gemgento::User]
    def is_valid?(quantity, user = nil)
      return false unless self.user_group.nil? || (!user.nil? && self.user_group != user.user_group)
      return false unless quantity >= self.quantity
      return true
    end

    private

    def touch_product
      TouchProduct.perform_async(self.product.id, true)
    end

  end
end