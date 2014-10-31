# This migration comes from gemgento (originally 20141028215239)
class AddGiftMessageToGemgentoQuote < ActiveRecord::Migration
  def change
    add_column :gemgento_quotes, :gift_message, :text, after: :gift_message_id
  end
end
