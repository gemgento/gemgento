module Gemgento
  class User::SavedCreditCardsController < User::BaseController

    def index
      @saved_credit_cards = current_user.saved_credit_cards
    end

    def new
      @saved_credit_card = SavedCreditCard.new(user: current_user)
      @saved_credit_card.build_address(country: Gemgento::Country.find_by(iso2_code: 'us'))
    end

    def create
      @saved_credit_card = SavedCreditCard.new(saved_credit_card_params)
      @saved_credit_card.user = current_user

      respond_to do |format|
        if @saved_credit_card.save
          format.html { redirect_to user_saved_credit_cards_path, notice: 'Saved credit card successfully created.' }
          format.json { render json: { result: true } }
        else
          format.html { render 'new' }
          format.json { render json: { result: false, errors: @saved_credit_card.errors.full_messages }, status: 422 }
        end
      end
    end

    def destroy
      @saved_credit_card = SavedCreditCard.find_by(user: current_user, id: params[:id])

      respond_to do |format|
        if @saved_credit_card.destroy
          format.html { redirect_to user_saved_credit_cards_path, notice: 'Saved credit card successfully destroyed.' }
          format.json { render json: { result: true } }
        else
          format.html { redirect_to user_saved_credit_cards_path, alert: 'Saved credit card could not be destroyed.' }
          format.json { render json: { result: false, errors: @saved_credit_card.errors.full_messages }, status: 422 }
        end
      end
    end

    private

    def saved_credit_card_params
      params.require(:saved_credit_card).permit(
          :id, :cc_type, :cc_number, :cc_exp_month, :cc_exp_year,
          address_attributes:
              [
                  :id, :first_name, :last_name, :address1, :address2, :country_id, :city, :region_id, :postcode,
                  :telephone, :is_billing, :is_shipping, :copy_to_user
              ],
      )
    end

  end
end