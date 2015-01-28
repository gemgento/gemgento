module Gemgento

  # @author Gemgento LLC
  class WishlistItem < ActiveRecord::Base
    belongs_to :product
    belongs_to :user
  end
end
