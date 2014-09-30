module Gemgento
  class OrderPayment < ActiveRecord::Base
    belongs_to :order

    validates :cc_owner, :cc_type, :cc_exp_month, :cc_exp_year, :cc_cid, :cc_number, presence: true, if: 'payment_id.blank?'

    attr_accessor :cc_number, :cc_cid, :save_card, :payment_id
  end
end