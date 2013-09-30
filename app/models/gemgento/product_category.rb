module Gemgento
  class ProductCategory < ActiveRecord::Base
    belongs_to :product
    belongs_to :category

    default_scope -> { order(:position) }
  end
end