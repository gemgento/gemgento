module Gemgento
  class ApplyPriceRule
    include Sidekiq::Worker

    def perform(price_rule_id)
      price_rule = PriceRule.find(price_rule_id)
      touched = false

      Product.active.each do |product|
        Store.all.each do |store|
          break if touched
          next unless price_rule.stores.include?(store)

          if PriceRule.meets_condition?(price_rule.conditions, product, store)
            product.set_cache_expires_at
            touched = true
          end
        end

        touched = false
      end
    end
  end
end