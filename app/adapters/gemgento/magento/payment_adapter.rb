module Gemgento
  class Magento::PaymentAdapter

    attr_accessor :source, :payable

    def initialize(source, payable)
      @source = source
      @payable = payable
    end

    # @return [Gemgento::Payment]
    def import
      payment = Gemgento::Payment.find_or_initialize_by(magento_id: self.source[:payment_id])
      payment.payable = self.payable
      payment.magento_id = self.source[:payment_id]
      payment.increment_id = self.source[:increment_id]
      payment.is_active = self.source[:is_active]
      payment.amount_ordered = self.source[:amount_ordered]
      payment.shipping_amount = self.source[:shipping_amount]
      payment.base_amount_ordered = self.source[:base_amount_ordered]
      payment.base_shipping_amount = self.source[:base_shipping_amount]
      payment.method = self.source[:method]
      payment.po_number = self.source[:po_number]
      payment.cc_type = self.source[:cc_type]
      payment.cc_number_enc = self.source[:cc_number_enc]
      payment.cc_last4 = self.source[:cc_last4]
      payment.cc_owner = self.source[:cc_owner]
      payment.cc_exp_month = self.source[:cc_exp_month]
      payment.cc_exp_year = self.source[:cc_exp_year]
      payment.cc_ss_start_month = self.source[:cc_ss_start_month]
      payment.cc_ss_start_year = self.source[:cc_ss_start_year]
      payment.save!

      return payment
    end

  end
end