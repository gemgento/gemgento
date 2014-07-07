require 'shopify_api'

module Gemgento::Adapter
  class ShopifyAdapter < ActiveRecord::Base
    belongs_to :gemgento_model, polymorphic: true

    def self.api_url
      "https://#{Gemgento::Config[:adapter][:shopify][:api_key]}:#{Gemgento::Config[:adapter][:shopify][:password]}@#{Gemgento::Config[:adapter][:shopify][:shop_name]}.myshopify.com/admin"
    end

    def self.import_all
    Shopify::Product.import
      Shopify::Customer.import
      Shopify::Order.import
    end

    def shopify_model
      if self.shopify_model_type.blank? || self.shopify_model_id.blank?
        return nil
      else
        ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url
        return self.shopify_model_type.constantize.find(self.shopify_model_id)
      end
    end

  end
end