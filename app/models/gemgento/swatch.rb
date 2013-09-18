module Gemgento
  class Swatch < ActiveRecord::Base
    has_many :products

    has_attached_file :image
  end
end