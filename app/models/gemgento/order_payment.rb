module Gemgento
  class OrderPayment < ActiveRecord::Base
    belongs_to :order

    attr_accessor :cc_number, :cc_cid

    def self.cc_types
      {
          'Credit card type' => nil,
          VI: 'Visa',
          MC: 'MasterCard',
          AE: 'American Express',
          DI: 'Discover',
          OT: 'Other'
      }
    end
  end
end