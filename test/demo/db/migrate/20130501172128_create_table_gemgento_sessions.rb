class CreateTableGemgentoSessions < ActiveRecord::Migration
  def change
    
    create_table :gemgento_sessions do |t|
      t.string     :session_id
      t.timestamps
    end

  end
end
