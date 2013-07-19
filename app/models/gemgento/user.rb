# TODO: add a validation to make sure a users doesn't add ':' to their password

module Gemgento
  class User < ActiveRecord::Base
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    belongs_to :user_group
    belongs_to :store
    has_many   :addresses

    after_save :sync_local_to_magento

    def self.index
      if User.find(:all).size == 0
        API::SOAP::Customer::Customer.fetch_all
      end

      User.find(:all)
    end

    def self.is_valid_login(email, password)
      user = User.find_by(email: email)

      if user.nil? || !user.is_valid_password(password)
        user = nil
      end

      user
    end

    def is_valid_password(password)
      unless self.encrypted_password.nil?
        return self.valid_password?(password)
      else
        # NOTE: this method is untested, but should replicate the Magento encrypted password
        salt = self.password.split(':')[1]
        encrypted_password = OpenSSL::HMAC.hexdigest('sha256', salt + password, Gemgento::Config[:magento][:encryption])
        encrypted_password += ':' + salt
        puts encrypted_password

        return self.password == encrypted_password
      end
    end

    def get_default_address(type)
      type =
      address = self.addresses.find_by("is_default_#{type}" => true)

      address = Address.new if address.nil?

      address
    end

    private

    # Push local users changes to magento
    def sync_local_to_magento
      # Password needs to be past as plain text.  It will be encrypted by Magento and updated.
      if self.sync_needed
        if !self.magento_id
          API::SOAP::Customer::Customer.create(self)
        else
          API::SOAP::Customer::Customer.update(self)
        end

        self.sync_needed = false
        self.save
      end
    end
  end
end