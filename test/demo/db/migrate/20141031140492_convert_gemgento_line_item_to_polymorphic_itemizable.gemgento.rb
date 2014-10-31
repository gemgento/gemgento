# This migration comes from gemgento (originally 20141028150806)
class ConvertGemgentoLineItemToPolymorphicItemizable < ActiveRecord::Migration
  def change
    rename_column :gemgento_line_items, :order_id, :itemizable_id
    add_column :gemgento_line_items, :itemizable_type, :string, default: 'Gemgento::Order', after: :magento_id
    add_index :gemgento_line_items, [:itemizable_type, :itemizable_id]
  end

  def up
    super
    change_column_default :gemgento_line_items, :itemizable_type, :null
  end
end
