module Gemgento

  # @author Gemgento LLC
  class RelationType < ActiveRecord::Base
    has_many :relations, dependent: :destroy
  end
end
