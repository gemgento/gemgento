module Gemgento

  # @author Gemgento LLC
  class PriceRule < ActiveRecord::Base
    serialize :conditions, Hash

    has_and_belongs_to_many :stores, join_table: 'gemgento_price_rules_stores', class_name: 'Store'
    has_and_belongs_to_many :user_groups, join_table: 'gemgento_price_rules_user_groups', class_name: 'UserGroup'

    after_save :apply, if: -> { changed? }

    default_scope ->{ order(sort_order: :asc) }
    scope :active, -> { where(is_active: true) }

    # Calculate a product price based on PriceRules.
    #
    # @param product [Gemgento::Product]
    # @param user_group [Gemgento::UserGroup]
    # @param store [Gemgento::Store]
    # @return [Float]
    def self.calculate_price(product, user_group = nil, store = nil)
      store ||= Store.current
      price = product.attribute_value('price', store).to_f
      user_group ||= UserGroup.find_by(magento_id: 0)

      PriceRule.active.each do |price_rule|
        if price_rule.is_valid?(product, user_group, store)
          price = price_rule.calculate(price)
          return price if price_rule.stop_rules_processing?
        end
      end

      return price
    end

    # Determines if the rule is valid for a product.
    #
    # @param product [Gemgento::Product]
    # @param user_group [Gemgento::UserGroup]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def is_valid?(product, user_group, store)
      if !self.is_active?
        return false
      elsif !self.stores.include?(store)
        return false
      elsif !self.user_groups.include?(user_group)
        return false
      elsif !self.from_date.nil? && Date.today < from_date
        return false
      elsif !self.to_date.nil? && Date.today > to_date
        return false
      else
        return PriceRule.meets_condition?(self.conditions, product, store)
      end
    end

    # Calculate the discount based on rule actions.
    #
    # @param price [Float]
    # @return Float
    def calculate(price)
      case self.simple_action
      when 'to_fixed'
        return [self.discount_amount.to_f, price].min
      when 'to_percent'
        return price * self.discount_amount.to_f / 100
      when 'by_fixed'
        return [0, price - self.discount_amount.to_f].max
      when 'by_percent'
        return price * (1 - self.discount_amount.to_f / 100)
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
    def self.meets_condition_product?(condition, product, store)
      if condition['attribute'] == 'category_ids'
        return meets_category_condition?(condition, product, store)
      elsif condition['attribute'] == 'attribute_set_id'
        return meets_attribute_set_condition?(condition, product)
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
      magento_category_ids = ProductCategory.where(product: product, store: store).includes(:category).map{ |pc| pc.category.magento_id unless pc.category.nil? }.uniq
      condition_category_ids = condition['value'].split(',').map(&:to_i)

      case condition['operator']
        when *%w[== {} ()]
          return (magento_category_ids & condition_category_ids).any?
        when *%w[!= !{} !()]
          return (magento_category_ids & condition_category_ids).empty?
        else
          return false
      end
    end

    # Determines if a product meets an attribute set based condition.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @return [Boolean]
    def self.meets_attribute_set_condition?(condition, product)
      magento_attribute_set_id = product.product_attribute_set.magento_id
      condition_attribute_set_id = condition['value'].to_i

      case condition['operator']
        when *%w[== {} ()]
          return magento_attribute_set_id == condition_attribute_set_id
        when *%w[!= !{} !()]
          return magento_attribute_set_id != condition_attribute_set_id
        else
          return false
      end
    end

    # Determines if a product meets an attribute based condition.
    #
    # @param condition [Hash]
    # @param product [Gemgento::Product]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def self.meets_attribute_condition?(condition, product, store)
      return false unless attribute = ProductAttribute.find_by(code: condition['attribute'])

      product_value = product.attribute_value(attribute.code, store).to_s.downcase

      if attribute.frontend_input == 'select'
        return false unless option = attribute.product_attribute_options.find_by(value: condition['value'], store: store)
        condition_value = option.label.downcase
      else
        condition_value = condition['value'].downcase
      end

      case condition['operator']
        when '==' # is
          return product_value == condition_value
        when '!=' # is not
          return product_value != condition_value
        when '>=' # equals or greater than
          return product_value >= condition_value
        when '<=' # equals or less than
          return product_value <= condition_value
        when '>' # greater than
          return product_value > condition_value
        when '<' # less than
          return product_value < condition_value
        when '{}' # contains
          return product_value.include?(condition_value)
        when '!{}' # does not contain
          return !product_value.include?(condition_value)
        when '()' # is one of
          return condition_value.split(',').map(&:strip).include?(product_value)
        when '!()' # is not one of
          return !condition_value.split(',').map(&:strip).include?(product_value)
        else
          return false
      end
    end

    # Get the earliest date and time that a price rule will expire for a given product.
    #
    # @param product [Gemgento::Product]
    # @param user_group [Gemgento::UserGroup]
    # @param store [Gemgento::Store]
    # @return [DateTime, nil]
    def self.first_to_expire(product, user_group, store)
      expires_at = nil

      PriceRule.active.each do |price_rule|
        next if price_rule.to_date.nil?

        if price_rule.is_valid?(product, user_group, store)
          if expires_at.nil? || price_rule.to_date.end_of_day < expires_at
            expires_at = price_rule.to_date.end_of_day
          end
        end
      end

      return expires_at
    end

    private

    # Touch products affected by the PriceRule
    #
    # @return [Void]
    def apply
      ApplyPriceRule.perform_async(self.id)
    end

  end
end