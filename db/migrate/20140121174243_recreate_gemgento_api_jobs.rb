class RecreateGemgentoApiJobs < ActiveRecord::Migration
  def up
    drop_table :gemgento_api_jobs

    create_table :gemgento_api_jobs, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8', force: true do |t|
      t.integer :source_id
      t.string :kind
      t.string :state
      t.string :source_type
      t.string :request_url
      t.text :request
      t.text :response
      t.boolean :locked
      t.text :request_body
      t.string :request_status
      t.string :response_status
      t.string :type
      t.timestamps
    end
  end

  def down
    # don't do anything
  end
end
