module Gemgento
  class User::RecurringProfilesController < User::BaseController

    def index
      @recurring_profile = RecurringProfile.where(user: current_user)
    end

    def destroy
      recurring_profile = RecurringProfile.find_by!(id: params[:id], user: current_user)

      respond_to do |format|
        result = recurring_profile.change_state('cancel')

        if result == true
          format.json { render json: { status: true } }
          format.html do
            flash[:notice] = 'The recurring profile has been canceled.'
            redirect_to action: 'index'
          end
        else
          format.json { render json: { errors: result }, status: 422 }
          format.html do
            flash[:warning] = result
            redirect_to action: 'index'
          end
        end
      end
    end

  end
end