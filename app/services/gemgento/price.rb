module Gemgento
  class Price

    attr_accessor :product, :store, :user

    def initialize(product, user, store)
      @product = product
      @store = store
      @user = user
    end

    def calculate
      if product.magento_type == 'giftvoucher'
        return gift_price
      elsif self.has_special?
        return product.attribute_value('special_price', store).to_f
      else
        return Gemgento::PriceRule.calculate_price(product, user, store)
      end
    end

    # If product is a gift, determine gift value.
    #
    # @return [BigDecimal]
    def gift_price
      store = Gemgento::Store.current if store.nil?

      case self.attribute_value('gift_price_type', store)
        when 'Fixed number'
          return self.attribute_value('gift_price', store).to_d
        when 'Percent of Gift Card value'
          return self.attribute_value('gift_value', store).to_d * (self.attribute_value('gift_price', store).to_d / 100.0)
        else
          return self.attribute_value('gift_value', store).to_d
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