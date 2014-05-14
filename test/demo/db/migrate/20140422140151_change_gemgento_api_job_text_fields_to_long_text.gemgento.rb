# This migration comes from gemgento (originally 20140209233713)
class ChangeGemgentoApiJobTextFieldsToLongText < ActiveRecord::Migration
  def up
    change_column :gemgento_api_jobs, :response, :longtext
    change_column :gemgento_api_jobs, :request, :longtext
    change_column :gemgento_api_jobs, :request_body, :longtext
  end

  def down
    change_column :gemgento_api_jobs, :response, :text
    change_column :gemgento_api_jobs, :request, :text
    change_column :gemgento_api_jobs, :request_body, :text
  end
end
