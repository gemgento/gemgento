module Gemgento::Adapter::Shopify
  class Address

    # Import Shopify address to Gemgento
    #
    # @param address [ShopifyAPI::Address]
    # @param user [Gemgento::User]
    # @param is_default [Boolean]
    def self.import(address, user, is_default)
      address = Gemgento::Address.new

    end

  end
end