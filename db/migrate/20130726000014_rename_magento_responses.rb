class RenameMagentoResponses < ActiveRecord::Migration
  def change
    rename_table :magento_responses, :gemgento_magento_responses
  end
end
