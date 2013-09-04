module Gemgento
  module API
    module SOAP
      module Customer
        class Customer

          def self.fetch_all(last_updated = nil)
            list.each do |store_view|
              store_view[:item].each do |customer|
                sync_magento_to_local(customer)
              end
            end
          end

          def self.fetch_all_customer_groups
            group.each do |customer_group|
              sync_magento_customer_group_to_local(customer_group)
            end
          end

          def self.list
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

          def self.create(customer)
            message = {
                customer_data: compose_customer_data(customer)
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

          def self.update(customer)
            message = {
                customer_id: customer.magento_id,
                customer_data: compose_customer_data(customer)
            }
            response = Gemgento::Magento.create_call(:customer_customer_update, message)

            if response.success?
              unless customer.magento_password.include? ':'
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
            user = Gemgento::User.where(magento_id: source[:customer_id]).first_or_initialize
            user.magento_id = source[:customer_id]
            user.increment_id = source[:increment_id]
            user.store = Store.find_by(magento_id: source[:store_id])
            user.created_in = source[:created_in]
            user.email = source[:email]
            user.fname = source[:firstname]
            user.mname = source[:middlename]
            user.lname = source[:lastname]
            user.user_group = UserGroup.where(magento_id: source[:group_id]).first
            user.prefix = source[:prefix]
            user.suffix = source[:suffix]
            user.dob = source[:dob]
            user.taxvat = source[:taxvat]
            user.confirmation = source[:confirmation]
            user.magento_password = source[:password_hash]
            user.sync_needed = false
            user.save(validate: false)

            Gemgento::API::SOAP::Customer::Address.fetch(user.magento_id)
          end

          def self.compose_customer_data(customer)
            customer_data = {
                email: customer.email,
                firstname: customer.fname,
                middlename: customer.mname,
                lastname: customer.lname,
                'store_id' => customer.store.magento_id,
                'group_id' => customer.user_group.magento_id,
                'website_id' => '1',
                prefix: customer.prefix,
                suffix: customer.suffix,
                dob: customer.dob,
                taxvat: customer.taxvat
            }

            unless customer.magento_password.include? ':'
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