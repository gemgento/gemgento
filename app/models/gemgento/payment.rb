module Gemgento
  class Payment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true

    attr_accessor :cc_number, :cc_cid, :save_card, :payment_id

    validates :cc_owner, :cc_type, :cc_exp_month, :cc_exp_year, :cc_cid, :cc_number, presence: true, if: 'payment_id.blank?'
    validates :payable, presence: true
  end
end