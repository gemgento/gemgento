module Gemgento

  # @author Gemgento LLC
  class PriceRule < ActiveRecord::Base
    default_scope ->{ order(sort_order: :asc) }
    serialize :conditions, Hash

    # Calculate a product price based on PriceRules.
    #
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return Float
    def self.calculate_price(product, store = nil)
      price = product.attribute_value('price', store).to_f

      PriceRule.all.each do |price_rule|
        if price_rule.is_valid?(product, store)
          price = price_rule.calculate(price)
        end

        return price if price_rule.stop_rules_processing?
      end

      return price
    end

    # Determines if the rule is valid for a product.
    #
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def is_valid?(product, store)
      if !self.is_active?
        return false
      elsif !self.from_date.nil? && Date.today < from_date
        return false
      elsif !self.to_date.nil? && Date.today > to_date
        return false
      else
        return Gemgento::PriceRule.meets_condition?(self.conditions, product, store)
      end
    end

    # Calculate the discount based on rule actions.
    #
    # @param price [Float]
    # @return Float
    def calculate(price)
      case self.simple_action
      when 'to_fixed'
        return [self.discount_amount, price].min
      when 'to_percent'
        return price * self.discount_amount / 100
      when 'by_fixed'
        return [0, price - self.discount_amount].max
      when 'by_percent'
        return price * (1- self.discount_amount / 100)
      else
        return price
      end
    end

    # Determines if the condition is met.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def self.meets_condition?(condition, product, store)
      if condition['type'] == 'catalogrule/rule_condition_combine'
        return meets_condition_combine?(condition, product, store)
      elsif condition['type'] == 'catalogrule/rule_condition_product'
        return meets_condition_product?(condition, product, store)
      else
        return false # non-determinable condition type
      end
    end

    # Determines if the combined child conditions are met.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def self.meets_condition_combine?(condition, product, store)
      return true if condition['conditions'].nil?

      condition['conditions'].each do |child_condition|

        if meets_condition?(child_condition, product, store) # the condition has been met
          if condition['aggregator'] == 'all' && condition['value'] == '0' # all conditions not met
            return false
          elsif condition['aggregator'] == 'any' && condition['value'] == '1' # any condition met
            return true
          end

        else # the condition has not be met
          if condition['aggregator'] == 'all' && condition['value'] == '1' # all conditions met
            return false
          elsif condition['aggregator'] == 'any' && condition['value'] == '0' # any condition not be met
            return true
          end
        end
      end

      if condition['aggregator'] == 'all' # all conditions evaluated and all met
        return true
      else # all conditions evaluated and none met
        return false
      end
    end

    # Determines if the product conditions are met.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def self.meets_condition_product?(condition, product)
      if condition['attribute'] == 'category_ids'
        return meets_category_condition?(condition, product, store)
      elsif condition['attribute'] == 'attribute_set_id'
        return meets_attribute_set_condition?(condition, product, store)
      else
        return meets_attribute_condition?(condition, product, store)
      end
    end

    # Determines if a product meets a category based condition.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def self.meets_category_condition?(condition, product, store)
      magento_category_ids = product.categories.pluck(:magento_id).uniq
      condition_category_ids = condition['value'].split(',').map(&:to_i)
      category_union = magento_category_ids & condition_category_ids
      return condition['operator'] == '==' ? category_union.any? : category_union.empty?
    end

    # Determines if a product meets an attribute set based condition.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def self.meets_attribute_set_condition?(condition, product, store)
      magento_attribute_set_id = product.product_attribute_set.magento_id
      condition_attribute_set_id = condition['value'].to_i

      if condition['operator'] == '=='
        return magento_attribute_set_id == condition_attribute_set_id
      else
        return magento_attribute_set_id != condition_attribute_set_id
      end
    end

    # Determines if a product meets an attribute based condition.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def self.meets_attribute_condition?(condition, product, store)
      return false unless attribute = Gemgento::ProductAttribute.find_by(code: condition['attribute'])

      if attribute.frontend_input == 'select'
        return false unless option = attribute.product_attribute_options.find_by(value: condition['value'], store: store)
        value = option.label
      else
        value = condition['value']
      end

      if condition['operator'] == '=='
        return product.attribute_value(attribute.code, store) == value
      else
        return product.attribute_value(attribute.code, store) != value
      end
    end
  end
end