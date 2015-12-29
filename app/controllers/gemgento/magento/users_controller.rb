module Gemgento
  module Magento
    class UsersController < Gemgento::Magento::BaseController

      def update
        retry_count ||= 0
        data = params[:data]

        @user = Gemgento::User.find_or_initialize_by(magento_id: params[:id])
        @user.increment_id = data[:increment_id]
        @user.created_in = data[:created_in]
        @user.email = data[:email]
        @user.first_name = data[:firstname]
        @user.middle_name = data[:middlename]
        @user.last_name = data[:lastname]
        @user.user_group = Gemgento::UserGroup.find_by!(magento_id: data[:group_id])
        @user.prefix = data[:prefix]
        @user.suffix = data[:suffix]
        @user.dob = data[:dob]
        @user.taxvat = data[:taxvat]
        @user.confirmation = data[:confirmation]
        @user.gender = data[:gender]

        if @user.magento_password != data[:password_hash]
          @user.encrypted_password = ''
          @user.magento_password = data[:password_hash]
        end

        @user.sync_needed = false
        @user.save validate: false

        if data[:store_id].to_i > 0
          store = Gemgento::Store.find_by(magento_id: data[:store_id])
        elsif !data[:website_id].nil?
          store = Gemgento::Store.find_by(website_id: data[:website_id])
        else
          store = Gemgento::Store.current
        end

        @user.stores << store unless @user.stores.include?(store)

        Gemgento::API::SOAP::Authnetcim::Payment.fetch(@user) if Config[:extensions]['authorize-net-cim-payment-module']

        render nothing: true

      # try one more time to create the record, duplicate record errors are common with threads
      rescue ActiveRecord::RecordInvalid => e
        (retry_count += 1) <= 1 ? retry : raise(e)

      rescue ActiveRecord::RecordNotUnique => e
        (retry_count += 1) <= 1 ? retry : raise(e)
      end

      def destroy
        @user = User.find_by(magento_id: params[:id])
        @user.mark_deleted! unless @user.nil?

        render nothing: true
      end

    end
  end
end