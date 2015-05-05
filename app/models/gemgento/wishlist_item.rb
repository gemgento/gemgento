module Gemgento

  # @author Gemgento LLC
  class WishlistItem < ActiveRecord::Base
    belongs_to :product
    belongs_to :user

    validates :product, :user, presence: true
    validates :product, uniqueness: { scope: :user }
  end
end
