module Gemgento
  module API
    module SOAP
      module Customer
        class Customer

          def self.fetch_all(last_updated = nil)
            list(last_updated).each do |store_view|

              unless store_view[:item].nil?
                # enforce array
                unless store_view[:item].is_a? Array
                  store_view[:item] = [store_view[:item]]
                end

                store_view[:item].each do |customer|
                  sync_magento_to_local(customer)
                end
              end
            end
          end

          def self.fetch(customer_id)
            sync_magento_to_local(info(customer_id))
          end

          def self.fetch_all_customer_groups
            group.each do |customer_group|
              sync_magento_customer_group_to_local(customer_group)
            end
          end

          def self.list(last_updated = nil)
            if last_updated.nil?
              message = {}
            else
              message = {
                  'filters' => {
                      'complex_filter' => {item: [
                          key: 'updated_at',
                          value: {
                              key: 'gt',
                              value: last_updated
                          }
                      ]}
                  }
              }
            end

            response = Gemgento::Magento.create_call(:customer_customer_list, message)

            if response.success?
              # enforce array
              unless response.body_overflow[:store_view].is_a? Array
                response.body_overflow[:store_view] = [response.body_overflow[:store_view]]
              end

              response.body_overflow[:store_view]
            end
          end

          def self.info(customer_id)
            response = Gemgento::Magento.create_call(:customer_customer_info, {customer_id: customer_id})

            if response.success?
              response.body[:customer_info]
            end
          end

          def self.create(customer, store)
            message = {
                customer_data: compose_customer_data(customer, store)
            }
            response = Gemgento::Magento.create_call(:customer_customer_create, message)

            if response.success?
              customer.magento_id = response.body[:result]
              customer.sync_needed = false
              customer.save

              # pull customer information to get the password
              sync_magento_to_local(info(customer.magento_id))
            end
          end

          def self.update(customer, store)
            message = {
                customer_id: customer.magento_id,
                customer_data: compose_customer_data(customer, store)
            }
            response = Gemgento::Magento.create_call(:customer_customer_update, message)

            if response.success?
              if customer.magento_password.nil? || !customer.magento_password.include?(':')
                # pull customer information to get the password
                sync_magento_to_local(info(customer.magento_id))
              end
            end
          end

          def self.delete
            message = {
                customer_id: customer.magento_id
            }
            response = Gemgento::Magento.create_call(:customer_customer_delete, message)

            return response.success?
          end

          def self.group
            response = Gemgento::Magento.create_call(:customer_group_list)

            if response.success?
              unless response.body[:result][:item].is_a? Array
                response.body[:result][:item] = [response.body[:result][:item]]
              end

              response.body[:result][:item]
            end
          end

          private

          # Save a Magento customer as local users
          def self.sync_magento_to_local(source)
            user = Gemgento::User.find_by(magento_id: source[:customer_id])

            if user.nil?
              user = Gemgento::User.where(email: source[:email]).first_or_initialize
            end

            user.magento_id = source[:customer_id]
            user.increment_id = source[:increment_id]
            user.stores << Gemgento::Store.find_by(magento_id: source[:store_id]) unless source[:store_id] == '0' || user.stores.include?(Gemgento::Store.find_by(magento_id: source[:store_id]))
            user.created_in = source[:created_in]
            user.email = source[:email]
            user.first_name = source[:firstname]
            user.middle_name = source[:middlename]
            user.last_name = source[:lastname]
            user.user_group = UserGroup.where(magento_id: source[:group_id]).first
            user.prefix = source[:prefix]
            user.suffix = source[:suffix]
            user.dob = source[:dob]
            user.taxvat = source[:taxvat]
            user.confirmation = source[:confirmation]
            user.magento_password = source[:password_hash]
            user.gender = source[:gender]
            user.sync_needed = false
            user.save(validate: false)

            Gemgento::API::SOAP::Customer::Address.fetch(user)
          end

          def self.compose_customer_data(customer, store)
            customer_data = {
                email: customer.email,
                firstname: customer.first_name,
                middlename: customer.middle_name,
                lastname: customer.last_name,
                'store_id' => store.magento_id,
                'group_id' => customer.user_group.magento_id,
                'website_id' => store.website_id,
                prefix: customer.prefix,
                suffix: customer.suffix,
                dob: customer.dob.nil? ? nil : "#{customer.dob.inspect} 00:00:00",
                taxvat: customer.taxvat,
                gender: customer.gender.nil? ? nil : customer.gender.to_i
            }

            unless customer.magento_password.nil? || customer.magento_password.include?(':')
              customer_data[:password] = customer.magento_password # pass plain text password, magento needs to encrypt it (stupid magento)
            end

            customer_data
          end

          def self.sync_magento_customer_group_to_local(source)
            customer_group = Gemgento::UserGroup.where(magento_id: source[:customer_group_id]).first_or_initialize
            customer_group.magento_id = source[:customer_group_id]
            customer_group.code = source[:customer_group_code]
            customer_group.save
          end

        end
      end
    end
  end
end