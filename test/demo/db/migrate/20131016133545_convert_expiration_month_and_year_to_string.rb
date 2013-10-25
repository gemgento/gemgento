class ConvertExpirationMonthAndYearToString < ActiveRecord::Migration
  def up
    change_column :gemgento_order_payments, :cc_exp_month, :string
    change_column :gemgento_order_payments, :cc_exp_year, :string
    change_column :gemgento_order_payments, :cc_ss_start_month, :string
    change_column :gemgento_order_payments, :cc_ss_start_year, :string
  end

  def down
    change_column :gemgento_order_payments, :cc_exp_month, :integer
    change_column :gemgento_order_payments, :cc_exp_year, :integer
    change_column :gemgento_order_payments, :cc_ss_start_month, :integer
    change_column :gemgento_order_payments, :cc_ss_start_year, :integer
  end
end
