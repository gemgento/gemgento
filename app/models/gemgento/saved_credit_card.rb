module Gemgento
  class SavedCreditCard < ActiveRecord::Base
    belongs_to :user
  end
end