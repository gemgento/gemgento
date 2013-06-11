module Gemgento
  class User < ActiveRecord::Base
    belongs_to :user_group
    belongs_to :store
    after_save :sync_local_to_magento

    def self.index
      if User.find(:all).size == 0
        fetch_all
      end

      User.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:customer_customer_list)

      # enforce array
      unless response[:store_view].is_a? Array
        response[:store_view] = [response[:store_view]]
      end

      response[:store_view].each do |store_view|

        # enforce array
        unless store_view[:item].is_a? Array
          store_view[:item] = [store_view][:item]
        end

        store_view[:item].each do |customer|
          sync_magento_to_local(customer)
        end
      end
    end

    private

    # Save a Magento customer as local user
    def self.sync_magento_to_local(source)
      user = User.find_or_initialize_by(magento_id: source[:customer_id])
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

    # Push local user changes to magento
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
          create_magento
        else
          update_magento
        end

        self.sync_needed = false
        self.save
      end
    end

    # Create a new Product in Magento and set out magento_id
    def create_magento
      message = {
          customer_data: compose_customer_data
      }
      create_response = Gemgento::Magento.create_call(:customer_customer_create, message)
      self.magento_id = create_response[:result]
    end

    # Update existing Magento Product
    def update_magento
      message = {
          customer_id:  self.magento_id,
          customer_data: compose_customer_data
      }
      update_response = Gemgento::Magento.create_call(:customer_customer_update, message)
    end

    def compose_customer_data
      customer_data = {
        email: self.email,
        firstname: self.fname,
        middlename: self.mname,
        lastname: self.lname,
        password: self.password,
        'store_id' => self.store.magento_id,
        'group_id' => self.user_group.magento_id,
        prefix: self.prefix,
        suffix: self.suffix,
        dob: self.dob,
        taxvat: self.taxvat
      }

      unless self.gender.null?
        customer_data.merge!({ gender: self.gender == male ? 1 : 2 })
      end

      customer_data
    end

    def delete_magento
      message = {
          customer_id: self.magento_id
      }
      delete_response = Gemgento::Magento.create_call(:customer_customer_delete, message)
    end
  end
end