class AddIsInUseToGemgentoSavedCreditCards < ActiveRecord::Migration
  def change
    add_column :gemgento_saved_credit_cards, :is_in_use, :boolean, default: false
  end
end
