module Gemgento
  module API
    module SOAP
      module Checkout
        class Customer

          def self.set(cart, customer)

            if cart.customer_is_guest
              customer = {
                  mode: 'guest',
                  email: cart.customer_email,
                  firstname: cart.billing_address.fname,
                  lastname: cart.billing_address.lname,
                  'website_id' => '1'
              }
            else
              customer = {
                  mode: 'customer',
                  'customer_id' => customer.magento_id,
                  email: customer.email,
                  firstname: customer.fname,
                  lastname: customer.lname,
                  password: customer.password,
                  confirmation: true,
                  'group_id' => customer.user_group.magento_id,
                  'website_id' => '1'
              }
            end

            message = {
                quote_id: cart.magento_quote_id,
                customer: customer,
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_customer_set, message)

            return response.success?
          end

          def self.address(cart)
            message = {
                quote_id: cart.magento_quote_id,
                customer: {item: compose_address_data([cart.shipping_address, cart.billing_address])},
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_customer_addresses, message)

            return response.success?
          end

          private

          def self.compose_address_data(addresses)
            address_data = []

            addresses.each do |address|
              address_data << {
                  mode: address.address_type,
                  firstname: address.fname,
                  lastname: address.lname,
                  company: address.company,
                  street: address.street,
                  city: address.city,
                  region: address.region_name,
                  'region_id' => address.region.magento_id,
                  postcode: address.postcode,
                  'country_id' => address.country.magento_id,
                  telephone: address.telephone,
                  fax: address.fax,
                  'is_default_billing' => (address.is_default and address.address_type = 'billing') ? 1 : 0,
                  'is_default_shipping' => (address.is_default and address.address_type = 'shipping') ? 1 : 0
              }
            end

            address_data
          end

        end
      end
    end
  end
end