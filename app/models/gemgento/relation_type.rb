module Gemgento
  class RelationType < ActiveRecord::Base
    has_many :relations, dependent: :destroy
  end
end
