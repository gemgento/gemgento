module Gemgento
  module API
    module SOAP
      module Checkout
        class Customer

          # Set the cart customer.
          #
          # @param [Order] cart
          # @param [User] customer
          # @return [Response]
          def self.set(cart)
            if cart.customer_is_guest
              customer = {
                  mode: 'guest',
                  email: cart.customer_email,
                  firstname: cart.billing_address.first_name,
                  lastname: cart.billing_address.last_name,
                  'website_id' => '1'
              }
            else
              customer = {
                  mode: 'customer',
                  'customer_id' => cart.user.magento_id,
                  email: cart.user.email,
                  firstname: cart.user.first_name,
                  lastname: cart.user.last_name,
                  password: cart.user.password,
                  confirmation: true,
                  'group_id' => cart.user.user_group.magento_id,
                  'website_id' => '1'
              }
            end

            message = {
                quote_id: cart.magento_quote_id,
                customer: customer,
                store_id: cart.store.magento_id
            }
            Magento.create_call(:shopping_cart_customer_set, message)
          end

          def self.address(cart)
            message = {
                quote_id: cart.magento_quote_id,
                customer: {item: compose_address_data([cart.shipping_address, cart.billing_address])},
                store_id: cart.store.magento_id
            }
            Magento.create_call(:shopping_cart_customer_addresses, message)
          end

          private

          def self.compose_address_data(addresses)
            address_data = []

            addresses.each do |address|
              address_data << {
                  mode: address.address_type,
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