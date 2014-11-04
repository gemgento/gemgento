module Gemgento

  # @author Gemgento LLC
  class StoreTag < ActiveRecord::Base
    belongs_to :tag, class_name: 'Tag'
    belongs_to :store, class_name: 'Store'
  end
end