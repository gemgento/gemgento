class AddGiftMessageToGemgentoQuote < ActiveRecord::Migration
  def change
    add_column :gemgento_quotes, :gift_message, :text, after: :gift_message_id
  end
end
