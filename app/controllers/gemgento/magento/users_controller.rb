module Gemgento
  class Magento::UsersController < MagentoController

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
      @user.user_group = Gemgento::UserGroup.where(magento_id: data[:group_id]).first
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

      @user.save

      if data[:store_id].to_i > 0
        store = Gemgento::Store.find_by(magento_id: data[:store_id])
      elsif !data[:website_id].nil?
        store = Gemgento::Store.find_by(website_id: data[:website_id])
      else
        store = Gemgento::Store.current
      end

      @user.stores << store unless @user.stores.include?(store)

      render nothing: true
    end

    def destroy
      @user = Gemgento::User.find_by(magento_id: params[:id])
      @user.mark_deleted! unless @user.nil?

      render nothing: true
    end

  end
end