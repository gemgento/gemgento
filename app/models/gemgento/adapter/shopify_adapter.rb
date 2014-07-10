require 'shopify_api'

module Gemgento::Adapter
  class ShopifyAdapter < ActiveRecord::Base
    belongs_to :gemgento_model, polymorphic: true

    validates :gemgento_model_type, :gemgento_model_id, :shopify_model_type, :shopify_model_id, presence: true
    validates :gemgento_model_id, uniqueness: {scope: :gemgento_model_type}

    def self.api_url
      "https://#{Gemgento::Config[:adapter][:shopify][:api_key]}:#{Gemgento::Config[:adapter][:shopify][:password]}@#{Gemgento::Config[:adapter][:shopify][:shop_name]}.myshopify.com/admin"
    end

    def self.import_all
      Shopify::Category.import
      Shopify::Product.import
      Shopify::Customer.import
      Shopify::Order.import
    end

    # Return the associated shopify model
    #
    # @return [Object]
    def shopify_model
      if self.shopify_model_type.blank? || self.shopify_model_id.blank?
        return nil
      else
        ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url
        return self.shopify_model_type.constantize.find(self.shopify_model_id)
      end
    end

    # Create a polymorphic association on shopify_model attributes
    #
    # @param model [Object]
    # @return [Void]
    def shopify_model=(model)
      self.shopify_model_type = model.class
      self.shopify_model_id = model.id
    end

    # Create a ShopifyAdapter for a given Gemgento model and Shopify model.
    #
    # @param gemgento_model [Object]
    # @param shopify_model [Object]
    # @return [Void]
    def self.create_association(gemgento_model, shopify_model)
      shopify_adapter = Gemgento::Adapter::ShopifyAdapter.new
      shopify_adapter.gemgento_model = gemgento_model
      shopify_adapter.shopify_model = shopify_model
      shopify_adapter.save
    end

    # Find a record by the shopify model.
    #
    # @param shopify_model [Object]
    # @param [Object, nil]
    def self.find_by_shopify_model(shopify_model)
      Gemgento::Adapter::ShopifyAdapter.find_by(shopify_model_type: shopify_model.class, shopify_model_id: shopify_model.id)
    end

  end
end