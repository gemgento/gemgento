module Gemgento

  # @author Gemgento LLC
  class Payment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true

    attr_accessor :cc_number, :cc_cid, :save_card, :payment_id

    validates :method, :payable, presence: true

    REDIRECTING_PAYMENT_METHODS = ['paypal_standard']

    def is_redirecting_payment_method?
      REDIRECTING_PAYMENT_METHODS.include? method
    end
  end
end