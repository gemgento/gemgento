require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Product

    def self.import
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      return fetch_all
    end

    def self.fetch_all
      ShopifyAPI::Product.all
    end

  end
end