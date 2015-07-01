module Gemgento
  class Price

    attr_accessor :product, :store, :user_group, :quantity

    # @param product [Gemgento::Product]
    # @param user_group [Gemgento::UserGroup]
    # @param store [Gemgento::Store]
    # @param quantity [Float]
    def initialize(product, user_group = nil, store = nil, quantity = 1.0)
      @product = product
      @store = store || Gemgento::Store.current
      @user_group = user_group
      @quantity = quantity
    end

    def calculate
      return gift_price if product.magento_type == 'giftvoucher'

      prices = []
      prices << product.original_price(store)
      prices << product.attribute_value('special_price', store).to_f if has_special?
      prices << Gemgento::PriceRule.calculate_price(product, user_group, store)
      prices << Gemgento::PriceTier.calculate_price(product, quantity, user_group, store)

      return prices.min
    end

    # If product is a gift, determine gift value.
    #
    # @return [BigDecimal]
    def gift_price
      store = Gemgento::Store.current if store.nil?

      case product.attribute_value('gift_price_type', store)
        when 'Fixed number'
          return product.attribute_value('gift_price', store).to_d
        when 'Percent of Gift Card value'
          return product.attribute_value('gift_value', store).to_d * (product.attribute_value('gift_price', store).to_d / 100.0)
        else
          return product.attribute_value('gift_value', store).to_d
      end
    end

    # Determine if a product has a valid special price set.
    #
    # @return [Boolean]
    def has_special?
      special_price = product.attribute_value('special_price', store)
      special_from_date = product.attribute_value('special_from_date', store)
      special_to_date = product.attribute_value('special_to_date', store)

      if special_price.nil? # no special price
        return false
      elsif special_from_date.nil? && special_to_date.nil?
        return true
      elsif special_from_date.nil? && !special_to_date.nil?
        return Date.parse(special_to_date) >= Date.today
      elsif special_to_date.nil? && !special_from_date.nil?
        return Date.parse(special_from_date) <= Date.today
      else
        return Date.parse(special_from_date) <= Date.today && Date.parse(special_to_date) >= Date.today
      end
    end

  end
end