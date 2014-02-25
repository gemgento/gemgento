module Gemgento
  class Magento::UsersController < Magento::MagentoBaseController

    def update
      @user = Gemgento::User.find_or_initialize_by(magento_id: params[:id])
      data = params[:data]

      @user.magento_id = params[:id]
      @user.increment_id = data[:increment_id]

      @user.created_in = data[:created_in]
      @user.email = data[:email]
      @user.first_name = data[:firstname]
      @user.middle_name = data[:middlename]
      @user.last_name = data[:lastname]
      @user.user_group = UserGroup.where(magento_id: data[:group_id]).first
      @user.prefix = data[:prefix]
      @user.suffix = data[:suffix]
      @user.dob = data[:dob]
      @user.taxvat = data[:taxvat]
      @user.confirmation = data[:confirmation]
      @user.gender = data[:gender]
      @user.sync_needed = false

      if @user.magento_password != data[:password_hash]
        @user.encrypted_password = ''
        @user.magento_password = data[:password_hash]
      end

      @user.save(validate: false)

      store = Store.find_by(magento_id: data[:store_id])
      @user.stores << store unless @user.stores.include?(store)

      render nothing: true
    end

  end
end