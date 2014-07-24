module Gemgento

  # @author Gemgento LLC
  class PriceRule < ActiveRecord::Base
    default_scope ->{ order(sort_order: :asc) }
    serialize :conditions, Hash

    # Determines if the condition is met.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @return [Boolean]
    def self.meets_condition?(condition, product)
      if condition['type'] == 'catalogrule/rule_condition_combine'
        return meets_condition_combine?(condition, product)
      elsif condition['type'] == 'catalogrule/rule_condition_product'
        return meets_condition_product?(condition, product)
      else
        return false # non-determinable condition
      end
    end

    # Determines if the combined child conditions are met.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @return [Boolean]
    def self.meets_condition_combine?(condition, product)
      condition['conditions'].each do |child_condition|

        if meets_condition?(child_condition, product) # the condition has been met
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
    # @return [Boolean]
    def self.meets_condition_product?(condition, product)
      if condition['attribute'] == 'category_ids'
        return meets_category_condition(condition, product)
      elsif condition['attribute'] == 'attribute_set_id'
        return meets_attribute_set_condition(condition, product)
      else
        return meets_attribute_condition(condition, product)

      end

    end

    # Determines if a product meets a category based condition.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @return [Boolean]
    def self.meets_category_condition(condition, product)
      magento_category_ids = product.categories.pluck(:magento_id).uniq
      condition_category_ids = condition['value'].split(',').map(&:to_i)
      category_union = magento_category_ids & condition_category_ids
      return condition['operator'] == '==' ? category_union.any? : category_union.empty?
    end

    # Determines if a product meets an attribute set based condition.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @return [Boolean]
    def self.meets_attribute_set_condition(condition, product)
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
    # @return [Boolean]
    def self.meets_attribute_condition(condition, product)
      return false unless attribute = Gemgento::ProductAttribute.find_by(code: condition['attribute'])

      if condition['operator'] == '=='
        return product.attribute_value(attribute.code) == condition['value']
      else
        return product.attribute_value(attribute.code) != condition['value']
      end
    end
  end
end