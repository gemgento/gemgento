require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Customer

    # Import all customers from Shopify.
    #
    # @return [Void]
    def self.import
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      ShopifyAPI::Customer.all.each do |customer|
        create_user(customer)
      end
    end

    # Create a user from Shopify customer.
    #
    # @param shopify_customer [ShopifyAPI::Customer]
    # @return [Gemgento::User]
    def create_user(shopify_customer)
      user = Gemgento::User.find_or_initialize_by(email: shopify_customer.email)
      user.first_name = shopify_customer.first_name
      user.last_name = shopify_customer.last_name
      user.user_group = Gemgento::UserGroup.find_by(code: 'General')
      user.sync_needed = true
      user.save

      Gemgento::Adapter::ShopifyAdapter.create_association(user, shopify_customer)

      return user
    end

  end
end