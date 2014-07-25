module Gemgento
  class Magento::PriceRulesController < MagentoController

    def update
      if data = params[:data]
        Gemgento::API::SOAP::CatalogRule::Rule.sync_magento_to_local(data, data[:website_ids], data[:customer_group_ids])
      end
      render nothing: true
    end

    def destroy
      if price_rule = Gemgento::PriceRule.find_by(magento_id: params[:id])
        price_rule.destroy
      end

      render nothing: true
    end

  end
end