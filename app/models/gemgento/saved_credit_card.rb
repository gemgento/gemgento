module Gemgento

  # @author Gemgento LLC
  class SavedCreditCard < ActiveRecord::Base
    belongs_to :user
  end
end