class CreateRelationTables < ActiveRecord::Migration
  def change
    create_table "gemgento_relation_types", :force => true do |t|
      t.string "name"
      t.text "description"
      t.string "applies_to"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "gemgento_relations", :force => true do |t|
      t.integer "relation_type_id"
      t.integer "relatable_id"
      t.string "relatable_type"
      t.integer "related_to_id"
      t.string "related_to_type"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  end
end
