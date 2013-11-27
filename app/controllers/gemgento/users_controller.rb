module Gemgento
  class UsersController < BaseController
    before_filter :auth_user, except: :update

    ssl_required :show, :update

    def show
      @user = current_user
    end

    def update
      @user = Gemgento::User.find_or_initialize_by(magento_id: params[:id])
      data = params[:data]

      @user.magento_id = params[:id]
      @user.increment_id = data[:increment_id]
      @user.store = Store.find_by(magento_id: data[:store_id])
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
      @user.magento_password = data[:password_hash]
      @user.sync_needed = false
      @user.save(validate: false)

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