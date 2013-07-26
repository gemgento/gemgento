class AddSuccessColumnToGemegentoMagentoResponses < ActiveRecord::Migration
  def change
    add_column :gemgento_magento_responses, :success, :boolean, default: false, null: false
  end
end
