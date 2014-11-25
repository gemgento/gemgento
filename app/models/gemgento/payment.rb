module Gemgento

  # @author Gemgento LLC
  class Payment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true

    attr_accessor :cc_number, :cc_cid, :save_card, :payment_id

    validates :method, :payable, presence: true

    REDIRECTING_PAYMENT_METHODS = {
        paypal_standard: { step: 'confirm' },
        paypal_express: { step: 'payment' }
    }

    def is_redirecting_payment_method?(step = nil)
      if REDIRECTING_PAYMENT_METHODS.has_key?(self.method.to_sym)
        if step.blank?
          return true
        else
          return REDIRECTING_PAYMENT_METHODS[self.method.to_sym][:step] == step
        end
      else
        return false
      end
    end

  end
end