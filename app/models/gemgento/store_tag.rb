module Gemgento
  class StoreTag < ActiveRecord::Base
    belongs_to :tag, class_name: 'Gemgento::Tag'
    belongs_to :store, class_name: 'Gemgento::Store'
  end
end