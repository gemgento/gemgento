module Gemgento
  module API
    module SOAP
      module Checkout
        class Customer

          # Set the cart customer.
          #
          # @param [Gemgento::Quote] quote
          # @param [Gemgento::User] customer
          # @return [Gemgento::MagentoResponse]
          def self.set(quote)
            if quote.customer_is_guest
              customer = {
                  mode: 'guest',
                  email: quote.customer_email,
                  firstname: quote.billing_address.first_name,
                  lastname: quote.billing_address.last_name,
                  'website_id' => '1'
              }
            else
              customer = {
                  mode: 'customer',
                  'customer_id' => quote.user.magento_id,
                  email: quote.user.email,
                  firstname: quote.user.first_name,
                  lastname: quote.user.last_name,
                  password: quote.user.password,
                  confirmation: true,
                  'group_id' => quote.user.user_group.magento_id,
                  'website_id' => '1'
              }
            end

            message = {
                quote_id: quote.magento_id,
                customer: customer,
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_customer_set, message)
          end

          # Set shipping and billing addreses for Quote in Magento.
          #
          # @param quote [Gemgento::Quote]
          # @return [Gemgento::MagentoResponse]
          def self.address(quote)
            message = {
                quote_id: quote.magento_id,
                customer: {item: compose_address_data([quote.shipping_address, quote.billing_address])},
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_customer_addresses, message)
          end

          private

          def self.compose_address_data(addresses)
            address_data = []

            addresses.each do |address|
              address_data << {
                  mode: address.is_billing ? 'billing' : (address.is_shipping ? 'shipping' : ''),
                  firstname: address.first_name,
                  lastname: address.last_name,
                  company: address.company,
                  street: address.street,
                  city: address.city,
                  region: address.region_name,
                  'region_id' => address.region.nil? ? nil : address.region.magento_id,
                  postcode: address.postcode,
                  'country_id' => address.country.magento_id,
                  telephone: address.telephone,
                  fax: address.fax,
                  'is_default_billing' => address.is_billing ? 1 : 0,
                  'is_default_shipping' => address.is_shipping ? 1 : 0
              }
            end

            address_data
          end

        end
      end
    end
  end
end