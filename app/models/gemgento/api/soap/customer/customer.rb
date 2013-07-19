module Gemgento
  module API
    module SOAP
      module Customer
        class Customer

          def self.fetch_all
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
            response = Gemgento::Magento.create_call(:customer_customer_list)

            # enforce array
            unless response[:store_view].is_a? Array
              response[:store_view] = [response[:store_view]]
            end

            response[:store_view]
          end

          def self.info(customer_id)
            response = Gemgento::Magento.create_call(:customer_customer_info, { customer_id: customer_id })
            response[:customer_info]
          end

          def self.create(customer)
            message = {
                customer_data: compose_customer_data(customer)
            }
            response = Gemgento::Magento.create_call(:customer_customer_create, message)
            puts response.inspect
            customer.magento_id = response[:result]
            customer.sync_needed = false
            customer.save

            # pull customer information to get the password
            sync_magento_to_local(info(customer.magento_id))
          end

          def self.update(customer)
            message = {
                customer_id:  customer.magento_id,
                customer_data: compose_customer_data(customer)
            }
            update_response = Gemgento::Magento.create_call(:customer_customer_update, message)

            unless customer.password.include? ':'
              # pull customer information to get the password
              sync_magento_to_local(info(customer.magento_id))
            end
          end

          def self.delete
            message = {
                customer_id: customer.magento_id
            }
            delete_response = Gemgento::Magento.create_call(:customer_customer_delete, message)
          end

          def self.group
            response = Gemgento::Magento.create_call(:customer_group_list)

            unless response[:result][:item].is_a? Array
              response[:result][:item] = [response[:result][:item]]
            end

            response[:result][:item]
          end

          private

          # Save a Magento customer as local users
          def self.sync_magento_to_local(source)
            user = Gemgento::User.find_or_initialize_by(magento_id: source[:customer_id])
            user.magento_id = source[:customer_id]
            user.increment_id = source[:increment_id]
            user.store = Store.find_by(magento_id: source[:store_id])
            user.created_in = source[:created_in]
            user.email = source[:email]
            user.fname = source[:firstname]
            user.mname = source[:middlename]
            user.lname = source[:lastname]
            user.user_group = UserGroup.find_by(magento_id: source[:group_id])
            user.prefix = source[:prefix]
            user.suffix = source[:suffix]
            user.dob = source[:dob]
            user.taxvat = source[:taxvat]
            user.confirmation = source[:confirmation]
            user.magento_password = source[:password_hash]
            user.sync_needed = false
            user.save
          end

          def self.compose_customer_data(customer)
            customer_data = {
                email: customer.email,
                firstname: customer.fname,
                middlename: customer.mname,
                lastname: customer.lname,
                'store_id' => customer.store.magento_id,
                'group_id' => customer.user_group.magento_id,
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
            customer_group = Gemgento::UserGroup.find_or_initialize_by(magento_id: source[:customer_group_id])
            customer_group.magento_id = source[:customer_group_id]
            customer_group.code = source[:customer_group_code]
            customer_group.save
          end

        end
      end
    end
  end
end