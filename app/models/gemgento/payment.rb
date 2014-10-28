module Gemgento
  class Payment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true

    attr_accessor :cc_number, :cc_cid, :save_card, :payment_id

    validates :cc_owner, :cc_type, :cc_exp_month, :cc_exp_year, :cc_cid, :cc_number, presence: true, if: 'payment_id.blank?'
    validates :payable, presence: true

    before_save :push_magento_quote_payment, if: "payable_type == 'Gemgento::Quote'"

    # Push Payment details to Magento.
    def push_magento_quote_payment
      response = API::SOAP::Checkout::Payment.method(self, self.payment)

      if response.success?
        self.cc_last4 = self.cc_number[-4..-1]
        return true
      else
        self.errors.add(:base, response.body[:faultstring])
        return false
      end
    end
  end
end