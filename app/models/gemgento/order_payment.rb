module Gemgento
  class OrderPayment < ActiveRecord::Base
    belongs_to :order

    def self.sync_magento_to_local(source, order)
      payment = OrderPayment.find_or_initialize_by(magento_id: source[:payment_id])
      payment.order = order
      payment.magento_id = source[:payment_id]
      #payment.increment_id = source[:increment_id]
      #payment.is_active = source[:is_active]
      payment.amount_ordered = source[:amount_ordered]
      payment.shipping_amount = source[:shipping_amount]
      payment.base_amount_ordered = source[:base_amount_ordered]
      payment.base_shipping_amount = source[:base_shipping_amount]
      payment.method = source[:method]
      payment.po_number = source[:po_number]
      payment.cc_type = source[:cc_type]
      payment.cc_number_enc = source[:cc_number_enc]
      payment.cc_last4 = source[:cc_last4]
      payment.cc_owner = source[:cc_owner]
      payment.cc_exp_month = source[:cc_exp_month]
      payment.cc_exp_year = source[:cc_exp_year]
      payment.cc_ss_start_month = source[:cc_ss_start_month]
      payment.cc_ss_start_year = source[:cc_ss_start_year]
      payment.save

      payment
    end
  end
end