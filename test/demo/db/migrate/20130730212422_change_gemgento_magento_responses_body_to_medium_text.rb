class ChangeGemgentoMagentoResponsesBodyToMediumText < ActiveRecord::Migration
  def change
    change_column :gemgento_magento_responses, :body, :mediumtext
  end
end
