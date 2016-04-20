module Gemgento

  # @author Gemgento LLC
  class Payment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true

    attr_accessor :cc_number, :cc_cid, :save_card, :payment_id

    before_save :set_cc_last4, if: Proc.new { |payment| payment.cc_number.present? || payment.payment_id.present? }

    validates :method, :payable, presence: true

    REDIRECTING_PAYMENT_METHODS = {
        paypal_standard: %w[confirm_after],
        paypal_express: %w[payment_after confirm_before]
    }

    def is_redirecting_payment_method?(step = nil)
      if REDIRECTING_PAYMENT_METHODS.has_key?(self.method.to_sym)
        if step.blank?
          return true
        else
          return REDIRECTING_PAYMENT_METHODS[self.method.to_sym].include? step
        end
      else
        return false
      end
    end

    # Set cc_last4 to the last 4 numbers of cc_number.
    #
    # @return [void]
    def set_cc_last4
      if self.cc_number.present?
        self.cc_last4 = cc_number[-4..-1]

      elsif saved_cc = Gemgento::SavedCreditCard.find_by(user: self.payable.user, token: self.payment_id)
        self.cc_last4 = saved_cc.cc_number.to_s[-4..-1]
      end
    end

    def is_new_credit_card_payment?
      payable_type == 'Gemgento::Quote' &&
          payable.converted_at.nil? &&
          !is_redirecting_payment_method? &&
          method != 'free' && payment_id.nil?
    end

  end
end