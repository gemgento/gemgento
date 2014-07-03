require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Order

    def self.import
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      return fetch_all
    end

    def fetch_all
      ShopifyAPI::Order.all
    end

  end
end