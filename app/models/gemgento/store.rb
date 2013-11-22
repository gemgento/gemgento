module Gemgento
  class Store < ActiveRecord::Base
    has_many :products
    has_many :users

    def self.current
      return Store.find_by(code: 'default')
    end

  end
end