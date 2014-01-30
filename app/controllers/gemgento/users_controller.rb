module Gemgento
  class UsersController < BaseController
    before_filter :auth_user, except: [:update, :index]

    respond_to :json, :html

    def index
      @user = current_user

      respond_with @user
    end

    def show
      @user = current_user

      respond_with @user
    end

    def update
      @user = Gemgento::User.find_or_initialize_by(magento_id: params[:id])
      data = params[:data]

      @user.magento_id = params[:id]
      @user.increment_id = data[:increment_id]

      @user.created_in = data[:created_in]
      @user.email = data[:email]
      @user.fname = data[:firstname]
      @user.mname = data[:middlename]
      @user.lname = data[:lastname]
      @user.user_group = UserGroup.where(magento_id: data[:group_id]).first
      @user.prefix = data[:prefix]
      @user.suffix = data[:suffix]
      @user.dob = data[:dob]
      @user.taxvat = data[:taxvat]
      @user.confirmation = data[:confirmation]
      @user.sync_needed = false
      @user.encrypted_password = ''
      @user.magento_password = data[:password_hash]
      @user.save(validate: false)

      store = Store.find_by(magento_id: data[:store_id])
      @user.stores << store unless @user.stores.include?(store)

      render nothing: true
    end

    private

    def auth_user
      redirect_to new_user_session_path unless user_signed_in?
    end

    def user_params
      params.require(:user).permit(:fname, :lname, :email, :mname, :prefix, :suffix, :password, :password_confirmation)
    end

  end
end