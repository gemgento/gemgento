# This migration comes from gemgento (originally 20140121164640)
class DropGemgentoOrderAddresses < ActiveRecord::Migration
  def up
    drop_table :gemgento_order_addresses
  end

  def down
    create_table "gemgento_order_addresses", force: true do |t|
      t.integer "order_id", null: false
      t.integer "increment_id"
      t.boolean "is_active", default: true, null: false
      t.string "address_type"
      t.string "fname"
      t.string "lname"
      t.string "company_name"
      t.string "street"
      t.string "city"
      t.string "region_name"
      t.integer "region_id"
      t.string "postcode"
      t.integer "country_id"
      t.string "telephone"
      t.string "fax"
      t.integer "address_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
