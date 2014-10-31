# This migration comes from gemgento (originally 20141028203630)
class AddQuoteReferenceToGemgentoOrder < ActiveRecord::Migration
  def change
    add_reference :gemgento_orders, :quote, index: true
  end
end
