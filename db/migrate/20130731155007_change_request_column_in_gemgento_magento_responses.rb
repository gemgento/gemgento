class ChangeRequestColumnInGemgentoMagentoResponses < ActiveRecord::Migration
  def change
    change_column :gemgento_magento_responses, :request, :mediumtext
  end
end
