module Gemgento::Adapter::Sellect
  class Customer < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym) if Gemgento::Config[:sellect]

    def self.import
      self.table_name = 'sellect_users'

      stores = Gemgento::Store.all

      self.all.each do |sellect_user|
        user = Gemgento::User.find_or_initialize_by(email: sellect_user.email)
        user.email = sellect_user.email
        user.first_name = sellect_user.first_name
        user.last_name = sellect_user.last_name
        user.dob = sellect_user.bday
        user.encrypted_password = sellect_user.encrypted_password
        user.magento_password = (0...8).map { (65 + rand(26)).chr }.join
        user.sign_in_count = sellect_user.sign_in_count
        user.current_sign_in_at = sellect_user.current_sign_in_at
        user.last_sign_in_at = sellect_user.last_sign_in_at
        user.current_sign_in_ip = sellect_user.current_sign_in_ip
        user.last_sign_in_ip = sellect_user.last_sign_in_ip
        user.user_group = Gemgento::UserGroup.find_by(code: 'General')
        user.sync_needed = false
        user.save(validate: false)

        user.stores = stores

        user.sync_needed = true
        user.save(validate: false)
      end
    end
  end
end