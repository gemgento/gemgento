require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Customer

    def self.import
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      ShopifyAPI::Customer.all.each do |customer|
        user = create_user(customer)
      end
    end

    # Create a user from Shopify customer.
    #
    # @param customer [ShopifyAPI::Customer]
    # @return [Gemgento::User]
    def create_user(customer)
      user = Gemgento::User.find_or_initialize_by(email: customer.email)
      return user
    end

  end
end