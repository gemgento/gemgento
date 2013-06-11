class AlterTableGemgentoCountries < ActiveRecord::Migration
  def up
    change_column :gemgento_countries, :magento_id, :string
  end

  def down
    change_column :gemgento_countries, :magento_id, :integer
  end
end
