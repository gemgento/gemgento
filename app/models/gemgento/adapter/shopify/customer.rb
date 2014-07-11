require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Customer

    # Import all customers from Shopify.
    #
    # @return [Void]
    def self.import
      page = 1
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      shopify_customers = ShopifyAPI::Customer.where(limit: 250, page: page)

      while shopify_customers.any?
        shopify_customers.each do |customer|
          user = create_user(customer)
          create_addresses(customer, user)
        end

        page = page + 1
        shopify_customers = ShopifyAPI::Customer.where(limit: 250, page: page)
      end
    end

    # Create a user from Shopify customer.
    #
    # @param shopify_customer [ShopifyAPI::Customer]
    # @return [Gemgento::User]
    def self.create_user(shopify_customer)
      if shopify_adapter = Gemgento::Adapter::ShopifyAdapter.find_by_shopify_model(shopify_customer)
        user = shopify_adapter.gemgento_model
      else
        user = Gemgento::User.new
      end

      user.email = shopify_customer.email
      user.first_name = shopify_customer.first_name
      user.last_name = shopify_customer.last_name
      user.user_group = Gemgento::UserGroup.find_by(code: 'General')
      user.stores = Gemgento::Store.all
      user.sync_needed = true
      user.save validate: false

      Gemgento::Adapter::ShopifyAdapter.create_association(user, shopify_customer)

      return user
    end

    # Import all addresses for a shopify customer.
    #
    # @param shopify_customer [ShopifyAPI::Customer]
    # @param user [Gemgento::User]
    # @return [Void]
    def self.create_addresses(shopify_customer, user)
      shopify_customer.addresses.each do |shopify_address|
        Gemgento::Adapter::Shopify::Address.import(shopify_address, user)
      end
    end

  end
end