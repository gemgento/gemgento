require 'shopify_api'

module Gemgento::Adapter
  class ShopifyAdapter

    def self.api_url
      "https://#{Gemgento::Config[:adapter][:shopify][:api_key]}:#{Gemgento::Config[:adapter][:shopify][:password]}@#{Gemgento::Config[:adapter][:shopify][:shop_name]}.myshopify.com/admin"
    end

    def self.import_all
    Shopify::Product.import
      Shopify::Customer.import
      Shopify::Order.import
    end

  end
end