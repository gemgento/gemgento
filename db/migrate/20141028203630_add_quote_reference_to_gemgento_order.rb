class AddQuoteReferenceToGemgentoOrder < ActiveRecord::Migration
  def change
    add_reference :gemgento_orders, :quote, index: true
  end
end
