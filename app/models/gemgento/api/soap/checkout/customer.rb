module Gemgento
  module API
    module SOAP
      module Checkout
        class Customer

          def self.set(cart, customer)
            message = {
                quote_id: cart.magento_quote_id,
                customer_data: {
                    mode: customer.magento_id.nil? ? 'guest' : 'customer',
                    'customer_id' => customer.magento_id,
                    email: customer.email,
                    firstname: customer.fname,
                    lastname: customer.lname,
                    password: customer.password,
                    confirmation: true,
                    'group_id' => customer.user_group.magento_id
                }
            }

            Gemgento::Magento.create_call(:shopping_cart_customer_set, message)
          end

          def self.addresses(cart, address)
            message = {
                quote_id: cart.magento_quote_id,
                customer_address_data: {
                    mode: address.type,
                    'address_id' => address.user_address_id,
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
                    'is_default_billing' => address.is_default_billing ? 1 : 0,
                    'is_default_shipping' => address.is_default_shipping ? 1 : 0
                }
            }

            Gemgento::Magento.create_call(:shopping_cart_customer_set, message)
          end

        end
      end
    end
  end
end