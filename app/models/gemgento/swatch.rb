module Gemgento
  class Swatch < ActiveRecord::Base
    belongs_to_many :products

    has_attached_file :image
  end
end