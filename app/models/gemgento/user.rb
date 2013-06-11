module Gemgento
  class User < ActiveRecord::Base
    belongs_to :user_group

    def self.index
      if User.find(:all).size == 0
        fetch_all
      end

      User.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:customer_customer_list)

      unless response[:store_view].is_a? Array
        response[:store_view] = [response[:store_view]]
      end

      response[:store_view].each do |store_view|
        unless response[:store_view][:item].is_a? Array
          response[:store_view][:item] = [response[:store_view][:item]]
        end

        response[:store_view][:item].each do |user|
          sync_magento_to_local(user)
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
      use.group = Group.find_by(magento_id: source[:group_id])
      user.prefix = source[:prefix]
      user.suffix = source[:suffix]
      user.dob = source[:dob]
      user.taxvat = source[:taxvat]
      user.confirmation = source[:confirmation]
      user.password = source[:password_hash]
      user.sync_needed = false
      user.save
    end
  end
end