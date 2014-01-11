module Gemgento
  class ProductCategory < ActiveRecord::Base
    belongs_to :product
    belongs_to :category
    belongs_to :store

    default_scope -> { where(store: Gemgento::Store.current).order(:position) }
  end
end