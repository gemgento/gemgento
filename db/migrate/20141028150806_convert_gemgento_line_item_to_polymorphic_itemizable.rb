class ConvertGemgentoLineItemToPolymorphicItemizable < ActiveRecord::Migration
  def change
    remove_index :gemgento_line_items, column: :order_id
    rename_column :gemgento_line_items, :order_id, :itemizable_id
    add_column :gemgento_line_items, :itemizable_type, :string, default: 'Gemgento::Order', after: :magento_id
    add_index :gemgento_line_items, [:itemizable_type, :itemizable_id]
  end

  def up
    super
    change_column_default :gemgento_line_items, :itemizable_type, :null
  end
end
