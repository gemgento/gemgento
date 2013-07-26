class RenameMagentoResponsesColumn < ActiveRecord::Migration
  def change
    rename_column :gemgento_magento_responses, :response, :body
  end
end
