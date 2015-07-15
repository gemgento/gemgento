module Gemgento

  # @author Gemgento LLC
  class Payment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true

    attr_accessor :cc_number, :cc_cid, :save_card, :payment_id

    before_save :set_cc_last4, unless: -> { cc_number.blank? }

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
      self.cc_last4 = cc_number[-4..-1]
    end

  end
end