require 'shopify_api'

module Gemgento::Adapter
  class ShopifyAdapter

    attr_accessor

    def initialize
      shop_url = "https://#{Gemgento::Config[:adapter][:shopify][:api_key]}:#{Gemgento::Config[:adapter][:shopify][:password]}@#{Gemgento::Config[:adapter][:shopify][:shop_name]}.myshopify.com/admin"
      ShopifyAPI::Base.site = shop_url
    end

    def import_products
      Shopify::Product.import
    end

    def import_customers
      Shopify::Customer.import
    end

    def import_orders
      Shopify::Order.import
    end

  end
end