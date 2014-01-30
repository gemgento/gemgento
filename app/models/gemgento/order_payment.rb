module Gemgento
  class OrderPayment < ActiveRecord::Base
    belongs_to :order

    validates :cc_owner, presence: true
    validates :cc_type, presence: true
    validates_with Gemgento::Validator::CcNumber, fields: [:cc_number], if: -> { Rails.env.production? }
    validates :cc_exp_month, presence: true
    validates :cc_exp_year, presence: true
    validates :cc_cid, presence: true

    attr_accessor :cc_number, :cc_cid
  end
end