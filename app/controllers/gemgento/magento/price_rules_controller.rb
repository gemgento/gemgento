module Gemgento
  class Magento::PriceRulesController < MagentoController

    def update
      pp params[:data]
      data = params[:data]
      price_rule = Gemgento::PriceRule.find_or_initialize_by(magento_id: params[:id])
      price_rule.name = data[:name]
      price_rule.description = data[:description]
      price_rule.from_date = data[:from_date]
      price_rule.to_date = data[:to_date]
      price_rule.is_active = data[:is_active]
      price_rule.stop_rules_processing = data[:stop_rules_processing]
      price_rule.sort_order = data[:sort_order]
      price_rule.simple_action = data[:simple_action]
      price_rule.discount_amount = data[:discount_amount]
      price_rule.sub_is_enable = data[:sub_is_enable]
      price_rule.sub_simple_action = data[:sub_simple_action]
      price_rule.sub_discount_amount = data[:sub_discount_amount]
      price_rule.conditions = data[:conditions]
      price_rule.save

      render nothing: true
    end

    def destroy
      price_rule.destroy if price_rule = Gemgento::ProductRule.find_by(magento_id: params[:id])
      render nothing: true
    end

  end
end