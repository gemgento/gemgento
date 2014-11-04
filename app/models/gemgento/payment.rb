module Gemgento

  # @author Gemgento LLC
  class Payment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true

    attr_accessor :cc_number, :cc_cid, :save_card, :payment_id

    validates :payable, presence: true
  end
end