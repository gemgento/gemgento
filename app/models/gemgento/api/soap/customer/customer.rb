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
            response = Gemgento::Magento.create_call(:customer_customer_list, { customer_id: customer_id })
            response[:customer_info]
          end

          def self.create(customer)
            message = {
                customer_data: compose_customer_data(customer)
            }
            response = Gemgento::Magento.create_call(:customer_customer_create, message)
            customer.magento_id = responsea[:result]
            customer.save
          end

          def self.update
            message = {
                customer_id:  customer.magento_id,
                customer_data: compose_customer_data(customer)
            }
            update_response = Gemgento::Magento.create_call(:customer_customer_update, message)
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

          # Push local user changes to magento
          def sync_local_to_magento(customer)
            if customer.sync_needed
              if !customer.magento_id
                create_magento
              else
                update_magento
              end

              customer.sync_needed = false
              customer.save
            end
          end

          private

          # Save a Magento customer as local user
          def self.sync_magento_to_local(source)
            user = GemgentoUser.find_or_initialize_by(magento_id: source[:customer_id])
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
            user.password = source[:password_hash]
            user.sync_needed = false
            user.save
          end

          def compose_customer_data(customer)
            customer_data = {
                email: customer.email,
                firstname: customer.fname,
                middlename: customer.mname,
                lastname: customer.lname,
                password: customer.password,
                'store_id' => customer.store.magento_id,
                'group_id' => customer.user_group.magento_id,
                prefix: customer.prefix,
                suffix: customer.suffix,
                dob: customer.dob,
                taxvat: customer.taxvat
            }

            unless customer.gender.null?
              customer_data.merge!({ gender: customer.gender == male ? 1 : 2 })
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