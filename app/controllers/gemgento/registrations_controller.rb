class RegistrationsController < Devise::RegistrationsController
  layout 'application'

  def create
    @user = User.create(params[:user])
    logger.info 'user = '+@user.inspect
    respond_to do |format|
  		if @user.save
        sign_in @user
        format.js { render 'successful_registration', :layout => false }
      else
        format.js { render 'errors', :layout => false }
      end
  	end
  end

end
