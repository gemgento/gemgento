# This migration comes from gemgento (originally 20140130180722)
class RenameNames < ActiveRecord::Migration
  def up
    rename_column :gemgento_addresses, :fname, :first_name
    rename_column :gemgento_addresses, :lname, :last_name
    rename_column :gemgento_addresses, :mname, :middle_name

    rename_column :gemgento_orders, :billing_fname, :billing_first_name
    rename_column :gemgento_orders, :billing_lname, :billing_last_name
    rename_column :gemgento_orders, :shipping_fname, :shipping_first_name
    rename_column :gemgento_orders, :shipping_lname, :shipping_last_name

    rename_column :gemgento_users, :fname, :first_name
    rename_column :gemgento_users, :lname, :last_name
    rename_column :gemgento_users, :mname, :middle_name

    rename_column :gemgento_subscribers, :fname, :first_name
    rename_column :gemgento_subscribers, :lname, :last_name
  end

  def down
    rename_column :gemgento_addresses, :first_name, :fname
    rename_column :gemgento_addresses, :last_name, :lname
    rename_column :gemgento_addresses, :middle_name, :mname

    rename_column :gemgento_orders, :billing_first_name, :billing_fname
    rename_column :gemgento_orders, :billing_last_name, :billing_lname
    rename_column :gemgento_orders, :shipping_first_name, :shipping_fname
    rename_column :gemgento_orders, :shipping_last_name, :shipping_lname

    rename_column :gemgento_users, :first_name, :fname
    rename_column :gemgento_users, :last_name, :lname
    rename_column :gemgento_users, :middle_name, :mname

    rename_column :gemgento_subscribers, :first_name, :fname
    rename_column :gemgento_subscribers, :last_name, :lname
  end
end
